module DemoMain where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.IO.Effect (INFINITY)
import Control.Monad.IOSync (IOSync, runIOSync)
import Data.Monoid (mempty)
import Data.Tuple (Tuple(..))
import Examples.Counter as Counter
import Specular.Dom.Browser (Node)
import Specular.Dom.Builder (Builder, el, runBuilder, text, weakDynamic_)
import Specular.FRP (Event, holdDyn, leftmost)
import Specular.FRP.Fix (fixFRP)

foreign import documentBody :: IOSync Node

type Demo = Builder Node Unit

demoButton :: String -> Builder Node Unit -> Builder Node (Event Demo)
demoButton name demo = do
  clicked <- Counter.buttonOnClick (pure mempty) (text name)
  pure $ demo <$ clicked

main :: Eff (infinity :: INFINITY) Unit
main = runIOSync $ do
  body <- documentBody
  void $ runBuilder { parent: body } mainWidget

mainWidget :: Builder Node Unit
mainWidget = fixFRP $ \view -> do
  el "h2" $ text "Current demo:"
  weakDynamic_ view.currentDemo 

  el "h2" $ text "Choose another demo:"
  chooseCounter <- demoButton "Counter" Counter.mainWidget

  let changeDemo = leftmost
        [ chooseCounter ]
  currentDemo <- holdDyn (text "(no demo chosen)") changeDemo

  pure (Tuple {currentDemo} unit)
