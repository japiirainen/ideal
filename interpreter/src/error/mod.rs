#![allow(dead_code)]

use std::fmt::{self, Display, Formatter};
use std::path::Path;
use std::sync::atomic::AtomicBool;
use std::sync::atomic::Ordering::SeqCst;

use colored::{ColoredString, Colorize};

use self::location::Location;

pub mod location;

static COLORED_OUTPUT: AtomicBool = AtomicBool::new(true);

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub enum DiagnosticKind {
    InternalError(&'static str),
}

impl DiagnosticKind {
    fn error_type(&self) -> ErrorType {
        match self {
            DiagnosticKind::InternalError(_) => ErrorType::Error,
        }
    }
}

impl Display for DiagnosticKind {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match self {
            DiagnosticKind::InternalError(message) => {
                write!(f, "`ideal` internal error: {}", message)
            }
        }
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum ErrorType {
    Error,
    Warning,
    Note,
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
pub struct Diagnostic<'a> {
    msg: DiagnosticKind,
    location: Location<'a>,
}

impl<'a> Diagnostic<'a> {
    pub fn new(location: Location<'a>, msg: DiagnosticKind) -> Diagnostic<'a> {
        Diagnostic { msg, location }
    }

    fn error_type(&self) -> ErrorType {
        self.msg.error_type()
    }

    fn marker(&self) -> ColoredString {
        match self.error_type() {
            ErrorType::Error => self.color("error:"),
            ErrorType::Warning => self.color("warning:"),
            ErrorType::Note => self.color("note:"),
        }
    }

    fn color(&self, msg: &str) -> ColoredString {
        match (COLORED_OUTPUT.load(SeqCst), self.error_type()) {
            (false, _) => msg.normal(),
            (_, ErrorType::Error) => msg.red(),
            (_, ErrorType::Warning) => msg.yellow(),
            (_, ErrorType::Note) => msg.purple(),
        }
    }

    pub fn display(&self) -> DisplayDiagnostic {
        DisplayDiagnostic(self)
    }

    fn format(&self, f: &mut Formatter) -> fmt::Result {
        let start = self.location.start;
        let relative_path = os_agnostic_display_path(self.location.filename);

        writeln!(
            f,
            "{}:{}:{}\t{} {}",
            relative_path,
            start.line,
            start.column,
            self.marker(),
            self.msg
        )?;

        // TODO: we need the source code here
        // for now just print the error

        Ok(())
    }
}

fn os_agnostic_display_path(path: &Path) -> ColoredString {
    let mut ret = String::new();

    for (i, component) in path.components().enumerate() {
        use std::path::Component;

        // Use / as the separator regardless of the host OS so
        // we can use the same tests for Linux/Mac/Windows
        if i != 0 && ret != "/" {
            ret += "/";
        }

        ret += match component {
            Component::CurDir => ".",
            Component::Normal(s) => s.to_str().expect("Path contains invalid utf-8"),
            Component::ParentDir => "..",
            Component::Prefix(_) => "",
            Component::RootDir => "/",
        }
    }

    if COLORED_OUTPUT.load(SeqCst) {
        ret.italic()
    } else {
        ret.normal()
    }
}

pub struct DisplayDiagnostic<'a>(&'a Diagnostic<'a>);

impl Display for DisplayDiagnostic<'_> {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        self.0.format(f)
    }
}
