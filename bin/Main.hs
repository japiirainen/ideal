module Main (main) where

import qualified Data.Text as Text
import qualified Ideal

main :: IO ()
main = putStrLn (Text.unpack Ideal.message)
