{-# LANGUAGE TypeFamilies, MultiParamTypeClasses, FlexibleInstances #-}
module Diagrams.Backend.Cairo where

import qualified Graphics.Rendering.Cairo as C

import Graphics.Rendering.Diagrams

import Diagrams.TwoD
import Diagrams.Path

data Cairo = Cairo

instance Backend Cairo where
  type BSpace Cairo = P2
  type Render Cairo = C.Render ()
  type Result Cairo = IO ()
  data Option Cairo = OutputFile String  -- XXX add more options!

  renderDia _ _ d = C.withPDFSurface "test.pdf" 100 100 $ \surface ->
                    C.renderWith surface (mapM_ (render Cairo) (prims d))

instance Renderable Box Cairo where
  render _ (Box v1 v2 v3 v4) = do
    C.newPath
    uncurry C.moveTo v1
    uncurry C.lineTo v2
    uncurry C.lineTo v3
    uncurry C.lineTo v4
    C.closePath
    C.stroke

instance Renderable Ellipse Cairo where
  render _ ell@(Ellipse a b c d e f) = do
--     let (xc,yc) = ellipseCenter ell
--     let (xs,ys) = ellipseScale ell
--     let th = ellipseAngle ell
    let (xc,yc,xs,ys,th) = ellipseCenterScaleAngle ell
    C.newPath
    C.save
    C.translate xc yc
    C.rotate th
    C.scale xs ys
    C.arc 0 0 1 0 (2*pi)
    C.closePath
    C.restore
    C.stroke

instance Renderable (Segment P2) Cairo where
  render _ (Linear v) = uncurry C.lineTo v
  render _ (Cubic v1 v2 v3) = undefined     -- XXX TODO

instance Renderable (RelPath P2) Cairo where
  render _ (RelPath segs) = do
    mapM_ (render Cairo) segs

instance Renderable (Path P2) Cairo where
  render _ (Path v r) = do
    C.newPath
    uncurry C.moveTo v
    render Cairo r
    C.stroke