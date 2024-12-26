-- | Haskell language pragma
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE BlockArguments #-}

-- | Haskell module declaration
module Ideal.Website (app, prerenderTo) where

-- | Miso framework import
import Miso
import Miso.String

import qualified Lucid as L
import qualified Data.Text as Text
import qualified Ideal

-- | Type synonym for an application model
type Model = Int

initialModel :: Model
initialModel = 0

-- | Sum type for application events
data Action
  = AddOne
  | SubtractOne
  | NoOp
  | SayHelloWorld
  deriving (Show, Eq)

-- | Entry point for a miso application
app :: JSM ()
app = miso \_url -> App {..}
  where
    initialAction = SayHelloWorld -- initial action to be executed on application load
    model  = initialModel
    update = updateModel          -- update function
    view   = viewModel            -- view function
    events = defaultEvents        -- default delegated events
    subs   = []                   -- empty subscription list
    mountPoint = Nothing          -- mount point for application (Nothing defaults to 'body')
    logLevel = Off                -- used during prerendering to see if the VDOM and DOM are in sync (only applies to `miso` function)

-- | Updates model, optionally introduces side effects
updateModel :: Action -> Model -> Effect Action Model
updateModel action m =
  case action of
    AddOne
      -> noEff (m + 1)
    SubtractOne
      -> noEff (m - 1)
    NoOp
      -> noEff m
    SayHelloWorld
      -> m <# do consoleLog Ideal.message >> pure NoOp

-- | Constructs a virtual DOM from a model
viewModel :: Model -> View Action
viewModel x = div_ [] [
   button_ [ onClick AddOne ] [ text "+" ]
 , text (ms x)
 , button_ [ onClick SubtractOne ] [ text "-" ]
 ]

 --------------------------------------------------------------------------------
-- Pre-rendering

prerenderTo :: FilePath -> IO ()
prerenderTo path = L.renderToFile path $ L.doctypehtml_ do
  L.head_ do
    L.meta_ [L.charset_ "utf-8"]
    L.meta_ [L.name_ "viewport", L.content_ "width=device-width, initial-scale=1"]
    L.title_ "Ideal"
  L.body_ do
    L.toHtml $ viewModel initialModel
    L.script_ [L.src_ "jsaddle.js"] Text.empty
    L.script_ [L.src_ "index.js", L.type_ "module"] Text.empty
