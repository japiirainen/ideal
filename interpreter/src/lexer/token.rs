#![allow(dead_code)]

#[derive(Debug, PartialEq, Eq, Clone, Copy)]
pub enum LexerError {
    InvalidCharacterInSignificantWhitespace(char),
    InvalidEscapeSequence(char),
    IndentChangeTooSmall,
    UnindentToNewLevel,
    Expected(char),
    UnknownChar(char),
}

#[derive(Debug, PartialEq, Clone)]
pub enum Token {
    EndOfInput,
    Invalid(LexerError),
}
