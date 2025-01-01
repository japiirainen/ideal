use clap::{Parser, Subcommand, ValueHint};

#[derive(Debug, Parser)]
#[command(author, version, about, long_about)]
pub struct Options {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
    #[command(arg_required_else_help = true)]
    Interpret {
        #[arg(value_hint=ValueHint::FilePath)]
        filepath: String,
    },
}
