#![allow(dead_code)]

use std::path::Path;

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct Position {
    pub index: usize,
    pub line: u32,
    pub column: u16,
}

impl Position {
    pub fn begin() -> Position {
        Position {
            index: 0,
            line: 1,
            column: 1,
        }
    }

    pub fn advance(&mut self, char_len: usize, passed_newline: bool) {
        if passed_newline {
            self.line += 1;
            self.column = 1;
        } else {
            self.column += 1;
        }
        self.index += char_len;
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub struct EndPosition {
    pub index: usize,
}

impl EndPosition {
    pub fn new(index: usize) -> EndPosition {
        EndPosition { index }
    }
}

#[derive(Debug, Clone, Copy)]
pub struct File<'c> {
    pub filename: &'c Path,
    pub contents: &'c str,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
pub struct Location<'c> {
    pub filename: &'c Path,
    pub start: Position,
    pub end: EndPosition,
}

impl Ord for Location<'_> {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        (self.start, self.end).cmp(&(other.start, other.end))
    }
}

impl PartialOrd for Location<'_> {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl<'c> Location<'c> {
    pub fn new(filename: &'c Path, start: Position, end: EndPosition) -> Location<'c> {
        Location {
            filename,
            start,
            end,
        }
    }

    pub fn length(&self) -> usize {
        self.end.index - self.start.index
    }

    pub fn union(&self, other: Location<'c>) -> Location<'c> {
        let start = if self.start.index < other.start.index {
            self.start
        } else {
            other.start
        };
        let end = if self.end.index < other.end.index {
            other.end
        } else {
            self.end
        };

        Location {
            filename: self.filename,
            start,
            end,
        }
    }

    #[allow(dead_code)]
    pub fn contains_index(&self, idx: &usize) -> bool {
        (self.start.index..self.end.index).contains(idx)
    }
}

/// A trait representing locatable entities during the interpretation pipeline.
pub trait Locatable<'a> {
    fn locate(&self) -> Location<'a>;
}
