# gpolygons_blockdesign.g
LoadPackage("design");
f := GF(3);
id := IdentityMat(2, f);;
clan := List( f, t -> t*id );;
clan := qClan(clan,f);
egq := EGQByqClan( clan );
HasElationGroup( egq );
design := BlockDesignOfGeneralisedPolygon( egq );;
aut := AutGroupBlockDesign( design );
NrBlockDesignPoints( design );
NrBlockDesignBlocks( design );
DisplayCompositionSeries(aut);
quit;
