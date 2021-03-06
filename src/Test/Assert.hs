module Test.Assert (runAssertions) where

import System.Console.ANSI (setSGR, SGR(..), ConsoleLayer(..), ColorIntensity(..), Color(..))
import System.Exit (exitSuccess, exitFailure)
import Text.Printf (printf)
import Data.Monoid (Monoid(..))

data Assertion = Assertion [(Color, String)] Integer Integer

instance Monoid Assertion where
  (Assertion a0 b0 c0) `mappend` (Assertion a1 b1 c1) = Assertion (a0++a1) (b0+b1) (c0+c1)
  mempty = Assertion [] 0 0

toAssertion :: (String, Bool) -> Assertion
toAssertion (s,b) = Assertion [(c,s)] p 1
  where (c, p) = if b then (Green,1) else (Red,0)

putOut :: (Color, String) -> IO ()
putOut (c,s) = setSGR [SetColor Foreground Dull c]
            >> putStrLn s
            >> setSGR []

showRatio :: Integer -> Integer -> String
showRatio a b = printf "%.2f" . (100*) $ ratio
  where ratio = (fromIntegral a) / (fromIntegral b) :: Float

assert :: Assertion -> IO ()
assert (Assertion out pass total) = do
  mapM_ putOut out
  putStrLn . concat $ [showRatio pass total, "% of tests passed."]
  if pass == total then exitSuccess else exitFailure

runAssertions :: [(String, Bool)] -> IO ()
runAssertions = assert . mconcat . map toAssertion
