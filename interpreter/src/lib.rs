mod error;
mod lexer;

use std::path::Path;

use self::error::location::{EndPosition, File, Location, Position};
use self::error::Diagnostic;
use self::lexer::Lexer;

pub fn interpret(filename: &Path, contents: String) -> Result<(), Diagnostic> {
    let lexer = Lexer::new(File {
        filename,
        contents: &contents,
    });

    for token in lexer {
        println!("{:?}", token);
    }

    Err(Diagnostic::new(
        Location::new(filename, Position::begin(), EndPosition::new(0)),
        error::DiagnosticKind::InternalError("Not implemented"),
    ))
}
