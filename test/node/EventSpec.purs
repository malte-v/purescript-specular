module EventSpec where

import Prelude hiding (append)

import Control.Monad.Cleanup (execCleanupT)
import Data.IORef (newIORef)
import Data.Maybe (Maybe(..))
import Specular.FRP (filterMapEvent, leftmost, mergeEvents, newBehavior, newEvent, sampleAt, subscribeEvent_)
import Test.Spec (Spec, describe, it)
import Test.Spec.Runner (RunnerEffects)
import Test.Utils (append, clear, ioSync, shouldHaveValue)

spec :: forall eff. Spec (RunnerEffects eff) Unit
spec = describe "Event" $ do

  it "pushes values to subscribers, honors unsubscribe" $ do
    {event,fire} <- ioSync newEvent
    log <- ioSync $ newIORef []
    unsub1 <- ioSync $ execCleanupT $ subscribeEvent_ (\x -> append log $ "1:" <> x) event
    unsub2 <- ioSync $ execCleanupT $ subscribeEvent_ (\x -> append log $ "2:" <> x) event
    ioSync $ fire "A"
    ioSync unsub1
    ioSync $ fire "B"

    log `shouldHaveValue` ["1:A", "2:A", "2:B"]

  describe "mergeEvents" $ do
    it "different root events" $ do
      root1 <- ioSync newEvent
      root2 <- ioSync newEvent
      log <- ioSync $ newIORef []

      let event = mergeEvents pure pure
                              (\l r -> pure $ "both: " <> l <> ", " <> r)
                              root1.event
                              root2.event
      _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

      clear log
      ioSync $ root1.fire "left"
      log `shouldHaveValue` ["left"]

      clear log
      ioSync $ root1.fire "right"
      log `shouldHaveValue` ["right"]

    it "coincidence" $ do
      root <- ioSync newEvent
      log <- ioSync $ newIORef []

      let event = mergeEvents
                    (\x -> pure $ "left: " <> x)
                    (\x -> pure $ "right: " <> x)
                    (\l r -> pure $ "both: " <> l <> ", " <> r)
                    root.event root.event

      _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

      ioSync $ root.fire "root"
      log `shouldHaveValue` ["both: root, root"]

  it "sampleAt" $ do
    root <- ioSync newEvent
    b <- ioSync $ newBehavior "A"
    log <- ioSync $ newIORef []

    let event = sampleAt root.event b.behavior
    _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

    ioSync $ root.fire ("1" <> _)
    ioSync $ b.set "B"
    ioSync $ root.fire ("2" <> _)
    log `shouldHaveValue` ["1A", "2B"]

  it "filterMapEvent" $ do
    root <- ioSync newEvent
    log <- ioSync $ newIORef []

    let event = filterMapEvent (\x -> if x < 5 then Just (2 * x) else Nothing) root.event
    _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

    ioSync $ root.fire 1
    ioSync $ root.fire 10
    ioSync $ root.fire 3
    ioSync $ root.fire 4
    log `shouldHaveValue` [2, 6, 8]

  describe "leftmost" $ do
    it "different root events" $ do
      root1 <- ioSync newEvent
      root2 <- ioSync newEvent
      log <- ioSync $ newIORef []

      let event = leftmost [ root1.event, root2.event ]
      _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

      clear log
      ioSync $ root1.fire "left"
      log `shouldHaveValue` ["left"]

      clear log
      ioSync $ root1.fire "right"
      log `shouldHaveValue` ["right"]

    it "coincidence chooses leftmost" $ do
      root <- ioSync newEvent
      log <- ioSync $ newIORef []

      let event = leftmost [ 1 <$ root.event, 2 <$ root.event, 3 <$ root.event ]

      _ <- ioSync $ execCleanupT $ subscribeEvent_ (append log) event

      ioSync $ root.fire unit
      log `shouldHaveValue` [ 1 ]