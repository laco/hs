module Hs
    ( emptyWorld
    , Dimension(..)
    , Snake(..)
    , updateWorld
    , Id(..)
    , Coordinate(..)
    , Event(..)
    , World(..)
    , Direction(..)
    , Apple(..)
    ) where

data Dimension = Dimension
  { width:: Int
  , height:: Int
  } deriving (Show, Eq)

data Coordinate = Coordinate
  { x:: Int
  , y:: Int
  } deriving (Show, Eq)

newtype Id = Id Int deriving (Eq, Show)

data Snake = Snake
  { snakeId:: Id
  , heading:: Direction
  , shead:: Coordinate
  , stail:: [Coordinate]
  } deriving (Show, Eq)

data Apple = Apple
  { position:: Coordinate
  } deriving (Show, Eq)

data World = World
  { dimension:: Dimension
  , snakes:: [Snake]
  , apples:: [Apple]
  } deriving (Show, Eq)

emptyWorld :: Dimension -> World
emptyWorld dim = World dim [] []

data Direction =
    North
  | South
  | West
  | East deriving (Show, Eq)

data Event =
    TurnSnake Id Direction
  | Step
  | AddSnake Snake
  | RemoveSnake Id deriving (Show)

updateWorld :: World -> Event -> World
updateWorld world (AddSnake snake) = let oldSnakes = snakes world
                                         newSnakeId = snakeId snake
                                         idAlreadyInUse = any (\s -> (snakeId s) == newSnakeId) oldSnakes
                                         newSnakes = if idAlreadyInUse then oldSnakes else snake:oldSnakes
                                     in world {snakes = newSnakes}

updateWorld world (TurnSnake sid direction) = let oldSnakes = snakes world
                                                  newSnakes = modifyElem (\snake -> (snakeId snake) == sid) (\snake -> snake { heading = direction}) oldSnakes 
                                              in world {snakes = newSnakes}

updateWorld world (RemoveSnake sid) = let oldSnakes = snakes world
                                          newSnakes = filter (\snake -> (snakeId snake) /= sid) oldSnakes
                                      in world {snakes = newSnakes}

updateWorld world Step = let oldSnakes = snakes world
                             newSnakes = map moveSnake oldSnakes
                         in world {snakes = newSnakes}


moveSnake :: Snake -> Snake
moveSnake snake = let newHead = calcNewHead snake
                      newTail = (shead snake) : (init (stail snake))
                  in snake {shead = newHead, stail = newTail}


calcNewHead :: Snake -> Coordinate
calcNewHead (Snake _ currentDirection (Coordinate x' y')  _) = case currentDirection of
                                                      North -> Coordinate x' (y' - 1)
                                                      South -> undefined
                                                      West -> undefined
                                                      East -> undefined



modifyElem :: Functor f => (a -> Bool )-> (a -> a)-> f a -> f a
modifyElem predicate modifier = fmap (\e -> if predicate e then modifier e else e)
