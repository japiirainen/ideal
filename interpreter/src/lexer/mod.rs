#![allow(dead_code)]

mod token;

use std::collections::HashMap;
use std::path::Path;
use std::str::Chars;

use crate::error::location::{File, Location, Position};

use self::token::Token;

#[derive(Clone)]
pub struct Lexer<'contents> {
    current: char,
    next: char,
    filename: &'contents Path,
    contents: &'contents str,
    token_start_position: Position,
    current_position: Position,
    indent_levels: Vec<IndentLevel>,
    current_indent_level: usize,
    return_newline: bool,
    previous_token_expects_indent: bool,
    chars: Chars<'contents>,
    keywords: HashMap<&'static str, Token>,
    open_braces: OpenBraces,
    pending_interpolations: Vec<usize>,
}

#[derive(Clone, Copy)]
struct IndentLevel {
    column: usize,
    ignored: bool,
}

impl IndentLevel {
    fn new(column: usize) -> IndentLevel {
        IndentLevel {
            column,
            ignored: false,
        }
    }

    fn ignore(column: usize) -> IndentLevel {
        IndentLevel {
            column,
            ignored: true,
        }
    }
}

#[derive(Clone, Copy)]
struct OpenBraces {
    parenthesis: usize,
    curly: usize,
    square: usize,
}

impl<'contents> Lexer<'contents> {
    pub fn keywords() -> HashMap<&'static str, Token> {
        vec![].into_iter().collect()
    }

    pub fn new(file: File<'contents>) -> Lexer<'contents> {
        let mut chars = file.contents.chars();
        let current = chars.next().unwrap_or('\0');
        let next = chars.next().unwrap_or('\0');
        Lexer {
            current,
            next,
            filename: file.filename,
            contents: file.contents,
            current_position: Position::begin(),
            token_start_position: Position::begin(),
            indent_levels: vec![IndentLevel::new(0)],
            current_indent_level: 0,
            return_newline: false,
            previous_token_expects_indent: false,
            chars,
            keywords: Lexer::keywords(),
            open_braces: OpenBraces {
                parenthesis: 0,
                curly: 0,
                square: 0,
            },
            pending_interpolations: Vec::new(),
        }
    }
}

impl<'contents> Iterator for Lexer<'contents> {
    type Item = (Token, Location<'contents>);

    fn next(&mut self) -> Option<Self::Item> {
        None
    }
}
