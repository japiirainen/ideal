module Worker where

import Ideal.Website qualified
import Language.Javascript.JSaddle.Wasm (JSVal)
import Language.Javascript.JSaddle.Wasm qualified as JSaddle.Wasm

foreign export javascript "hs_runWorker" runWorker :: JSVal -> IO ()

runWorker :: JSVal -> IO ()
runWorker = JSaddle.Wasm.runWorker Ideal.Website.app
