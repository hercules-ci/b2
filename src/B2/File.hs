{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}
{-# LANGUAGE TypeFamilies #-}
module B2.File
  ( File(..)
  , FileIDs(..)
  , HasFileID(..)
  , FileName(..)
  , HasFileName(..)
  , Files(..)
  ) where

import           Data.Aeson ((.:), (.:?), (.=))
import qualified Data.Aeson as Aeson
import           Data.Int (Int64)
import           Data.HashMap.Strict (HashMap)
import           Data.String (IsString)
import           Data.Text (Text)
import           Text.Printf (PrintfArg)

import           B2.ID (ID)


data File = File
  { fileIDs         :: FileIDs
  , contentLength   :: Int64
  , contentSha1     :: Maybe Text
  , contentType     :: Maybe Text
  , fileInfo        :: HashMap Text Text
  , action          :: Text
  , uploadTimestamp :: Int64
  } deriving (Show, Eq)

instance Aeson.FromJSON File where
  parseJSON =
    Aeson.withObject "File" $ \o -> do
      fileIDs <- Aeson.parseJSON (Aeson.Object o)
      contentLength <- o .: "contentLength"
      contentSha1 <- o .: "contentSha1"
      contentType <- o .: "contentType"
      fileInfo <- o .: "fileInfo"
      action <- o .: "action"
      uploadTimestamp <- o .: "uploadTimestamp"
      pure File {..}

instance Aeson.ToJSON File where
  toJSON File {fileIDs=FileIDs {..}, ..}=
    Aeson.object
      [ "fileId" .= fileID
      , "fileName" .= fileName
      , "contentLength" .= contentLength
      , "contentSha1" .= contentSha1
      , "contentType" .= contentType
      , "fileInfo" .= fileInfo
      , "action" .= action
      , "uploadTimestamp" .= uploadTimestamp
      ]

data FileIDs = FileIDs
  { fileID   :: ID File
  , fileName :: FileName
  } deriving (Show, Eq)

instance Aeson.FromJSON FileIDs where
  parseJSON =
    Aeson.withObject "FileIDs" $ \o -> do
      fileID <- o .: "fileId"
      fileName <- o .: "fileName"
      pure FileIDs {..}

instance Aeson.ToJSON FileIDs where
  toJSON FileIDs {..} =
    Aeson.object
      [ "fileId" .= fileID
      , "fileName" .= fileName
      ]

class HasFileID t where
  getFileID :: t -> ID File

instance file ~ File => HasFileID (ID file) where
  getFileID x = x

instance HasFileID FileIDs where
  getFileID = fileID

instance HasFileID File where
  getFileID File {..} = getFileID fileIDs

newtype FileName = FileName { unFileName :: Text }
    deriving (Show, Eq, IsString, PrintfArg, Aeson.FromJSON, Aeson.ToJSON)

class HasFileName t where
  getFileName :: t -> FileName

instance HasFileName FileName where
  getFileName x = x

instance HasFileName FileIDs where
  getFileName = fileName

instance HasFileName File where
  getFileName File {..} = getFileName fileIDs

data Files = Files
  { files        :: [File]
  , nextFileName :: Maybe Text
  , nextFileId   :: Maybe (ID File)
  } deriving (Show, Eq)

instance Aeson.FromJSON Files where
  parseJSON =
    Aeson.withObject "Files" $ \o -> do
      files <- o .: "files"
      nextFileName <- o .: "nextFileName"
      nextFileId <- o .:? "nextFileId"
      pure Files {..}

instance Aeson.ToJSON Files where
  toJSON Files {..} =
    Aeson.object
      [ "files" .= files
      , "nextFileName" .= nextFileName
      , "nextFileId" .= nextFileId
      ]
