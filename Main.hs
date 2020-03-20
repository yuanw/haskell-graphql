{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE ScopedTypeVariables   #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}

module Main where

import qualified Data.ByteString.Lazy.Char8 as B

import           Control.Monad.IO.Class     (liftIO)
import           Data.Morpheus              (interpreter)
import           Data.Morpheus.Document     (importGQLDocumentWithNamespace)
import           Data.Morpheus.Types        (GQLRootResolver (..), GQLType,
                                             IORes, Undefined (..))
import           Data.Text                  (Text)
import           GHC.Generics
import           Web.Scotty
--importGQLDocumentWithNamespace "schema.gql"

data Query m = Query
    { deity :: DeityArgs -> m Deity
    }
    deriving (Generic, GQLType)

data Deity = Deity
    { fullName :: Text -- Non-Nullable Field
    -- Nullable Field
    , power    :: Maybe Text -- Nullable Field
    }
    deriving (Generic, GQLType)

data DeityArgs = DeityArgs
    { name      :: Text -- Required Argument
    -- Optional Argument
    , mythology :: Maybe Text -- Optional Argument
    }
    deriving (Generic)

morpheus = Deity
      {
        fullName = "Morpheus"
      , power = (Just "Shapeshifting")
      }

rootResolver :: GQLRootResolver IO () Query Undefined Undefined
rootResolver = GQLRootResolver {
      queryResolver = Query (const $ pure morpheus),
      mutationResolver = Undefined,
      subscriptionResolver = Undefined
    }

api :: B.ByteString -> IO B.ByteString
api = interpreter rootResolver

main :: IO ()
main = scotty 3000 $ post "/api" $ raw =<< (liftIO . api =<< body)
