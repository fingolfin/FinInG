#############################################################################
##
##  polarspace.gi              FinInG package
##                                                              John Bamberg
##                                                              Anton Betten
##                                                              Jan De Beule
##                                                             Philippe Cara
##                                                            Michel Lavrauw
##                                                                 Maska Law
##                                                           Max Neunhoeffer
##                                                            Michael Pauley
##                                                             Sven Reichard
##
##  Copyright 2011	Colorado State University, Fort Collins
##					Università degli Studi di Padova
##					Universeit Gent
##					University of St. Andrews
##					University of Western Australia, Perth
##                  Vrije Universiteit Brussel
##                 
##
##  Implementation stuff for polar spaces
##
#############################################################################

########################################
#
# Things To Do:
#
# - Polarities as correlations
# - Documentation
# - test
# - make sure matrices are compressed.
# - think about the IsClassicalGQ filter. At first sight, we can leave everything as
#   is, since this will not affect correctness of the code.
# - to do: check if in constructors of standard polar spaces, the Wrap should be
#   replaced by VectorSpaceToElement
#
########################################
# Low level help methods:
#############################################################################

DESARGUES.LimitForCanComputeActionOnPoints := 1000000;
DESARGUES.Fast := true;

#############################################################################
# Constructor method (not for users)!:
#############################################################################

# CHECKED 20/09/11 jdb
#############################################################################
#O  Wrap( <geo>, <type>, <o> )
# This is an internal subroutine which is not expected to be used by the user;
# they would be using VectorSpaceToElement. Recall that Wrap is declared in 
# geometry.gd. 
##
InstallMethod( Wrap, 
	"for a polar space and an object",
	[IsClassicalPolarSpace, IsPosInt, IsObject],
	function( geo, type, o )
		local w;
		w := rec( geo := geo, type := type, obj := o );
		Objectify( NewType( SoPSFamily, IsElementOfIncidenceStructure and
		IsElementOfIncidenceStructureRep and IsSubspaceOfClassicalPolarSpace ), w );
    return w;
	end );

#############################################################################
# Constructor methods for polar spaces.
#############################################################################

# CHECKED 20/09/11 jdb
#############################################################################
#O  PolarSpace( <m>, <f>, <g>, <act> )
# This method returns a polar space with a lot of knowledge. most likely not for user.
# <m> is a sesquilinear form. Furthermore, a field <f>, a group <g> and an action 
# function <act> are given.
##
InstallMethod( PolarSpace, 
	"for a sesquilinear form, a field, a group and an action function",
	[ IsSesquilinearForm, IsField, IsGroup, IsFunction ],
	function( m, f, g, act )
		local geo,ty,gram;
		if IsDegenerateForm( m ) then 
			Error("Form is degenerate");
		elif IsPseudoForm( m ) then
			Error("No Polar space can be associated with a pseudo form");
		fi;
		gram := m!.matrix;
		geo := rec( basefield := f, dimension := Length(gram)-1,
					vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
								SesquilinearForm, m,
								CollineationGroup, g,
								CollineationAction, act,
								AmbientSpace, ProjectiveSpace(geo.dimension, f) );
		return geo;
	end );

#############################################################################
#O  PolarSpaceStandard( <m> )
# Method to crete a polar space using sesquilinear form <m>, where we know
# that this form is the standard one used in Fining. Not intended for users, 
# all checks are removed.
##
InstallMethod( PolarSpaceStandard, 
	"for a sesquilinear form",
	[ IsSesquilinearForm ],
	function( m )
		local geo, ty, gram, f;
		gram := m!.matrix;
		f := m!.basefield;
		geo := rec( basefield := f, dimension := Length(gram)-1,
				vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
                            SesquilinearForm, m,
                            AmbientSpace, ProjectiveSpace(geo.dimension, f),
							IsStandardPolarSpace, true );
		return geo;
	end );

#############################################################################
#O  PolarSpaceStandard( <m> )
# general method to create a polar space using quadratic form. Not intended 
# for the user. no checks.
##
InstallMethod( PolarSpaceStandard, 
	"for a quadratic form",
	[ IsQuadraticForm ],
	function( m )
		local geo, ty, gram, polar, f, flavour;
		f := m!.basefield;
		gram := m!.matrix;
		polar := AssociatedBilinearForm( m );
		geo := rec( basefield := f, dimension := Length(gram)-1,
					vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
								QuadraticForm, m,
								SesquilinearForm, polar,
								AmbientSpace, ProjectiveSpace(geo.dimension, f),
								IsStandardPolarSpace, true );
		return geo;
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#O  PolarSpace( <m> )
# general method to crete a polar space using sesquilinear form <m>. It is checked
# whether the form is not pseudo.##
##
InstallMethod( PolarSpace, 
	"for a sesquilinear form",
	[ IsSesquilinearForm ],
	function( m )
		local geo, ty, gram, f;
		if IsDegenerateForm( m ) then 
			Error("Form is degenerate");
		elif IsPseudoForm( m ) then
			Error("No Polar space can be associated with a pseudo form");
		fi;
		gram := m!.matrix;
		f := m!.basefield;
		geo := rec( basefield := f, dimension := Length(gram)-1,
				vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
                            SesquilinearForm, m,
                            AmbientSpace, ProjectiveSpace(geo.dimension, f),
							IsStandardPolarSpace, false );
		return geo;
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#O  PolarSpace( <m> )
#general method to create a polar space using quadratic form. Possible in even
#and odd char.
##
InstallMethod( PolarSpace, 
	"for a quadratic form",
	[ IsQuadraticForm ],
	function( m )
		local geo, ty, gram, polar, f, flavour;
		if IsSingularForm( m ) then 
			Error("Form is singular"); 
		fi;
		f := m!.basefield;
		gram := m!.matrix;
		polar := AssociatedBilinearForm( m );
		geo := rec( basefield := f, dimension := Length(gram)-1,
					vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
					IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
								QuadraticForm, m,
								SesquilinearForm, polar,
								AmbientSpace, ProjectiveSpace(geo.dimension, f),
								IsStandardPolarSpace, false );
		return geo;
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#O  PolarSpace( <m> )
# general method to setup a polar space using hermitian form. Is this method
# still necessary? Maybe not necessary, but maybe usefull, since we know slightly
# more properties of the polar space if we start from a hermitian form rather than
# from a sesquilinear form.
##
InstallMethod( PolarSpace, 
	"for a hermitian form",
	[ IsHermitianForm ],
	function( m )
		local geo, ty, gram, f;
		if IsDegenerateForm( m ) then 
			Error("Form is degenerate");
		fi;
		gram := m!.matrix;
		f := m!.basefield;
		geo := rec( basefield := f, dimension := Length(gram)-1,
					vectorspace := FullRowSpace(f,Length(gram)) );
		if WittIndex(m) = 2 then
			ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsClassicalGQ);
		else ty := NewType( GeometriesFamily,
                  IsClassicalPolarSpace and IsClassicalPolarSpaceRep );
		fi;
		ObjectifyWithAttributes( geo, ty, 
                            SesquilinearForm, m,
                            AmbientSpace, ProjectiveSpace(geo.dimension, f),
							IsStandardPolarSpace, false );
		return geo;
	end );


#############################################################################
## Constructions of Canonical finite classical Polar Spaces
## Important remark. We use "Canonical" in the mathematical sense, i.e, a polar
## space that equals one of the "standard" polar spaces constructed by the methods
## below. So "Standard" refers to a particular form used to construct the polar space. 
## It is well known that two forms that are similar, i.e. differe on a constant factor,
## will yield the same polar space. So a polar space is canonical iff its forms is similar with
## the form of one of the polar spaces constructed with a method below. A polar space is 
## "standard" iff it is constructed with one of the methods below. So if the user
## uses his favorite form, his polar space can become canonical, but it can never become standard.
#############################################################################

#############################################################################
# Part I: methods for canonical gram matrices and canonical quadratic forms.
# these methods are not intended for the user.
# This part also includes a method to setup the representative of the maximal 
# subspaces for polar spaces of each type.
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  CanonicalGramMatrix( <type>, <d>, <f> )
## Constructs the canonical gram matrix compatible with
## the corresponding matrix group in FinInG.
##
InstallMethod( CanonicalGramMatrix, 
	"for a string, an integer, and a field",
	[IsString, IsPosInt, IsField],
	function( type, d, f )
		local one, q, m, i, t, x, w, p;
		one := One( f );
		q := Size(f);

      # Symplectic Gram matrix
		if type = "symplectic" then    
			if IsOddInt(d) then
				Error( "the dimension <d> must be even" );
			fi;    
			m := List( 0 * IdentityMat(d, f), ShallowCopy );
			for i  in [ 1 .. d/2 ]  do
				m[2*i][2*i-1] := -one;
				m[2*i-1][2*i] := one;
			od;
    
      # Unitary Gram matrix      
		elif type = "hermitian" then
			if IsOddInt(PrimePowersInt(Size(f))[2]) then
				Error("field order must be a square");
			fi;
			m := IdentityMat(d, f);
        
      # Orthogonal Gram matrix
		elif type = "hyperbolic" then
			m := List( 0*IdentityMat(d, f), ShallowCopy );
			p := Characteristic(f);
			if IsOddInt(p) and (p + 1) mod 4 = 0 then
				w := one * ((p + 1) / 2);
			else
				w := one;
			fi; 
			for i  in [ 1 .. d/2 ]  do
				m[2*i-1][2*i] := w;
				m[2*i][2*i-1] := w;
			od;
		elif type = "elliptic" then   
			m := List( 0*IdentityMat(d, f), ShallowCopy );
			p := Characteristic(f);
      ## if q is congruent to 5,7 mod 8, then
      ## the anisotropic part is the primitive root.
			if q mod 4 in [1,2] then 
				t := Z(q);
			else
				t := one;
			fi;
			m{[1,2]}{[1,2]} := [ [ 1, 0 ], [ 0, t ] ] * one;

			if IsOddInt(p) then
				w := one * ((p + 1) / 2);
			else
				w := one;
			fi; 
			for i in [ 2 .. d/2 ]  do
				m[2*i-1][2*i] := w;
				m[2*i][2*i-1] := w;
			od;
		elif type = "parabolic" then 
			m := List( 0*IdentityMat(d, f), ShallowCopy );          
			p := Characteristic(f);
			if IsOddInt(p) then
         ## if q is congruent to 5,7 mod 8, then
         ## the anisotropic part is the primitive root
         ## of the prime subfield.
			if q mod 8 in [5,7] then 
				t := Z(p);
			else
				t := one;
			fi;
				m[1][1] := t;
				w := t * ((p + 1) / 2);
			else
				w := one;
			fi; 
			for i in [ 1 .. (d-1)/2 ]  do
				m[2*i][2*i+1] := w;
				m[2*i+1][2*i] := w;
			od;
		else Error( "type is unknown or not implemented" );
		fi;

    ##  We should return a compressed matrix in order that
    ##  our computations are efficient

		ConvertToMatrixRep( m, f );
		return m;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  CanonicalGramMatrix( <type>, <d>, <f> )
## Constructs the canonical quadric form compatible with
## the corresponding matrix group in FinInG.
## only used for q even.
##
InstallMethod( CanonicalQuadraticForm, 
	"for a string, an integer and a field",
	[IsString, IsPosInt, IsField],
	function( type, d, f )
		local m, one, q, p, j, x, R;
		one := One( f );
        if type = "hyperbolic" then
			m := MutableCopyMat(0 * IdentityMat(d, f));
			for j in [ 1 .. d/2 ]  do
				m[ 2*j-1 ][ 2*j ] := one;
			od;
		elif type = "elliptic" then
			m := MutableCopyMat(0 * IdentityMat(d, f));
			m[1][1] := one;
			m[2][1] := one; 
			m[d][d-1] := one;
			for j in [ 2 .. d/2-1 ]  do
				m[ 2*j-1 ][ 2*j ] := one;
			od;
			p := Characteristic(f);
			q := Size(f);
			if IsOddInt(Log(q, p)) then
				m[2][2] := one;
			else
				R := PolynomialRing( f, 1 );
				x := Indeterminate( f );
				m[2][2] := Z(q)^First( [ 0 .. q-2 ], u -> 
					Length( Factors( R, x^2+x+PrimitiveRoot( f )^u ) ) = 1 );         
			fi;
		elif type = "parabolic" then
			m := MutableCopyMat(0 * IdentityMat(d, f));
			m[1][1] := one;
			for j in [ 1 .. (d-1)/2 ]  do
				m[ 2*j+1 ][ 2*j ] := one;
			od;
		else Error( "type is unknown or not implemented" );
		fi;

    ##  We should return a compressed matrix in order that
    ##  our computations are efficient

		ConvertToMatrixRep( m, f );
		return m;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  CanonicalOrbitRepresentativeForSubspaces( <type>, <d>, <f> )
## This function returns representatives for the
## maximal totally isotropic (singular) subspaces
## of the given canonical polar space
##
InstallMethod( CanonicalOrbitRepresentativeForSubspaces, 
	"for a string, an integer and a field",
	[IsString, IsPosInt, IsField],		
	function( type, d, f )
		local b, i, id, one, w, q, sqrtq;
		q := Size(f);
		id := IdentityMat(d, f);
		if type = "symplectic" then    
			b := List([1..d/2], i-> id[2*i-1] + id[2*i]);
		elif type = "hermitian" then     
			one := One(f);
			sqrtq := Sqrt(q);
      ## find element with norm -1
			w := First(AsList(f), t -> IsZero( t^(sqrtq+1) + one ) );
			if IsEvenInt(d) then   
				b := List([1..d/2], i-> w * id[2*i] + id[2*i-1]);
			else 
				b := List([1..(d-1)/2], i-> w * id[2*i] + id[2*i-1]);
			fi;
		elif type = "parabolic" then 
			b := id{List([1..(d-1)/2], i -> 2*i)};
		elif type = "hyperbolic" then 
			b := id{List([1..d/2], i -> 2*i-1)};
		elif type = "elliptic" then 
			b := id{List([1..(d/2-1)],i -> 2*i+1)};
		else Error( "type is unknown or not implemented");
		fi;
		return [b];
	end );

#############################################################################
# Part II: constructor methods, for the user of course.
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  EllipticQuadric( <d>, <f> )
# returns the standard elliptic quadrac. See CanonicalQuadraticForm and CanonicalGramMatrix
# for details on the standard.
##
InstallMethod( EllipticQuadric, 
	"for an integer and a field",
	[ IsPosInt, IsField ],
	function( d, f )
		local eq,m,types,max,reps,q,form;
		q := Size(f);
		if IsEvenInt(d) then
			Error("dimension must be odd");
			return;
		fi;
		if IsEvenInt(q) then
			m := CanonicalQuadraticForm("elliptic", d+1, f);
			form := QuadraticFormByMatrix(m, f);
		else 
			m := CanonicalGramMatrix("elliptic", d+1, f);  
			form := BilinearFormByMatrix(m, f);  
		fi; 
        eq := PolarSpaceStandard( form );
		SetRankAttr( eq, (d-1)/2 );
		types := TypesOfElementsOfIncidenceStructure( AmbientSpace(eq) );
		SetTypesOfElementsOfIncidenceStructure(eq, types{[1..(d-1)/2]});
		SetIsEllipticQuadric(eq, true);
		SetIsCanonicalPolarSpace(eq, true);
		SetPolarSpaceType(eq, "elliptic");
		if RankAttr(eq) = 2 then
			SetOrder( eq, [q, q^2]);
		fi;
		max := CanonicalOrbitRepresentativeForSubspaces("elliptic", d+1, f)[1];

	## Here we take the maximal totally isotropic subspace rep
	## max and make representatives for lower dimensional subspaces
		reps := [ max[1] ];
		Append(reps, List([2..(d-1)/2], j -> max{[1..j]}));  

	## We would like the representative to be stored as
	## compressed matrices. Then they will be more efficient
	## to work with.
  
		for m in reps do
			if IsMatrix(m) then
				ConvertToMatrixRep(m,f);
			else 
				ConvertToVectorRep(m,f);
			fi;
		od;   

    ## Wrap 'em up
		reps := List([1..(d-1)/2], j -> Wrap(eq, j, reps[j]) );
		SetRepresentativesOfElements(eq, reps);
		SetClassicalGroupInfo( eq, rec( degree := (q^((d+1)/2)+1)*(q^((d+1)/2-1)-1)/(q-1) ) );  
		return eq;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  EllipticQuadric( <d>, <q> )
# returns the standard elliptic quadric. See EllipticQuadric method above.
##
InstallMethod( EllipticQuadric,
	"for two positive inteters <d> and <q>",	
	[ IsPosInt, IsPosInt ],
	function( d, q )  
		return EllipticQuadric(d,GF(q));
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  SymplecticSpace( <d>, <f> )
# returns the standard symplectic space. See CanonicalGramMatrix
# for details on the standard.
##
InstallMethod( SymplecticSpace,
	"for an integer and a field",
	[ IsPosInt, IsField ],
	function( d, f )
		local w,frob,m,types,max,reps,q,form;
		if IsEvenInt(d) then
			Error("dimension must be odd");
			return;
		fi;

	## put compressed matrices here also
		q := Size(f);
		m := CanonicalGramMatrix("symplectic", d+1, f);     
		w := PolarSpaceStandard( BilinearFormByMatrix(m, f) );
		SetRankAttr( w, (d+1)/2 );
		types := TypesOfElementsOfIncidenceStructure(AmbientSpace(w));
		if RankAttr(w) = 2 then
			SetOrder( w, [q, q]);
		fi;
		SetTypesOfElementsOfIncidenceStructure(w,types{[1..(d+1)/2]});
		SetIsSymplecticSpace(w,true);
		SetIsCanonicalPolarSpace(w, true);
		SetPolarSpaceType(w, "symplectic");
		max := CanonicalOrbitRepresentativeForSubspaces("symplectic", d+1, w!.basefield)[1];    

    ## Here we take the maximal totally isotropic subspace rep
    ## max and make representatives for lower dimensional subspaces
		reps := [ max[1] ];
		Append(reps, List([2..(d+1)/2], j -> max{[1..j]}));  

    ## We would like the representative to be stored as
    ## compressed matrices. Then they will be more efficient
    ## to work with.
		for m in reps do
			if IsMatrix(m) then
				ConvertToMatrixRep(m,f);
			else 
				ConvertToVectorRep(m,f);
			fi;
		od;   

    ## Wrap 'em up
		reps := List([1..(d+1)/2], j -> Wrap(w, j, reps[j]) );
		SetRepresentativesOfElements(w, reps);
        SetClassicalGroupInfo( w, rec(  degree := (q^(d+1)-1)/(q-1) ) );    
		return w;
	end );


# CHECKED 21/09/11 jdb
#############################################################################
#O  SymplecticSpace( <d>, <q> )
# returns the standard symplectic space. See SymplecticSpace method above.
##
InstallMethod(SymplecticSpace, 
	"for an integer and an integer",
	[ IsPosInt, IsPosInt ],
	function( d, q ) 
		return SymplecticSpace(d, GF(q));
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  ParabolicQuadric( <d>, <f> )
# returns the standard parabolic quadric. See CanonicalQuadraticForm and CanonicalGramMatrix
# for details on the standard.
##
InstallMethod( ParabolicQuadric, 
	"for an integer and a field",	
	[ IsPosInt, IsField ],
	function( d, f )
		local pq,m,types,max,reps,q,form;
		if IsOddInt(d) then
			Error("dimension must be even");
			return;
		fi;
		q := Size(f);
		if IsEvenInt(q) then
			m := CanonicalQuadraticForm("parabolic", d+1, f);
			form := QuadraticFormByMatrix(m, f);
		else 
			m := CanonicalGramMatrix("parabolic", d+1, f); 
			form := BilinearFormByMatrix(m, f);   
		fi; 
        pq := PolarSpaceStandard( form );
		SetRankAttr( pq, d/2 );
		types := TypesOfElementsOfIncidenceStructure( AmbientSpace(pq) );
		SetTypesOfElementsOfIncidenceStructure(pq, types{[1..d/2]});
		SetIsParabolicQuadric(pq, true);
		SetIsCanonicalPolarSpace(pq, true);
		SetPolarSpaceType(pq, "parabolic");
		if RankAttr(pq) = 2 then
			SetOrder( pq, [q, q]);
		fi;
		max := CanonicalOrbitRepresentativeForSubspaces("parabolic", d+1, f)[1];

    ## Here we take the maximal totally isotropic subspace rep
    ## max and make representatives for lower dimensional subspaces

		reps := [ max[1] ];
		Append(reps, List([2..d/2], j -> max{[1..j]}));  

    ## We would like the representative to be stored as
    ## compressed matrices. Then they will be more efficient
    ## to work with.
  
		for m in reps do
			if IsMatrix(m) then
				ConvertToMatrixRep(m,f);
			else 
				ConvertToVectorRep(m,f);
			fi;
		od;   

    ## Wrap 'em up
		reps := List([1..d/2], j -> Wrap(pq, j, reps[j]) );
		SetRepresentativesOfElements(pq, reps);
        SetClassicalGroupInfo( pq, rec( degree := (q^(d/2)-1)/(q-1)*(q^((d+2)/2-1)+1) ) );   
		return pq;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  ParabolicQuadric( <d>, <q> )
# returns the standard parabolic quadric. See ParabolicQuadric method above.
##
InstallMethod( ParabolicQuadric,
	"for two integers",
	[ IsPosInt, IsPosInt ],
	function( d, q ) 
		return ParabolicQuadric(d, GF(q));
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  HyperbolicQuadric( <d>, <f> )
# returns the standard hyperbolic quadric. See CanonicalQuadraticForm and CanonicalGramMatrix
# for details on the standard.
##
InstallMethod( HyperbolicQuadric, 
	"for an integer and a field",	
	[ IsPosInt, IsField ],
	function( d, f )
		local hq,m,types,max,reps,q,form;
		q := Size(f);
		if IsEvenInt(d) then
			Error("dimension must be odd");
			return;
		fi;
		if IsEvenInt(q) then
			m := CanonicalQuadraticForm("hyperbolic", d+1, f);
			form := QuadraticFormByMatrix(m, f);
		else 
			m := CanonicalGramMatrix("hyperbolic", d+1, f);    
			form := BilinearFormByMatrix(m, f);
		fi; 
		hq := PolarSpaceStandard( form );
		SetRankAttr( hq, (d+1)/2 );
		types := TypesOfElementsOfIncidenceStructure( AmbientSpace(hq) );
		SetTypesOfElementsOfIncidenceStructure(hq, types{[1..(d+1)/2]});
		SetIsCanonicalPolarSpace(hq, true);
		SetIsHyperbolicQuadric(hq, true);
		SetPolarSpaceType(hq, "hyperbolic");
		if RankAttr(hq) = 2 then
			SetOrder( hq, [q, 1]);
		fi;
		max := CanonicalOrbitRepresentativeForSubspaces("hyperbolic", d+1, f)[1];
  
    ## Here we take the maximal totally isotropic subspace rep
    ## max and make representatives for lower dimensional subspaces

		reps := [ max[1] ];
		Append(reps, List([2..(d+1)/2], j -> max{[1..j]}));  

    ## We would like the representative to be stored as
    ## compressed matrices. Then they will be more efficient
    ## to work with.
  
		for m in reps do
			if IsMatrix(m) then
				ConvertToMatrixRep(m,f);
			else 
				ConvertToVectorRep(m,f);
			fi;
		od;   

    ## Wrap 'em up
		reps := List([1..(d+1)/2], j -> Wrap(hq, j, reps[j]) );
		SetRepresentativesOfElements(hq, reps);
        SetClassicalGroupInfo( hq, rec( degree := (q^((d+1)/2)-1)/(q-1)*(q^((d+1)/2-1)+1)) );
		return hq;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  HyperbolicQuadric( <d>, <q> )
# returns the standard hyperbolic quadric. See HyperbolicQuadric method above.
##
InstallMethod(HyperbolicQuadric, 
	"for a two integers",
	[ IsPosInt, IsPosInt ],
	function( d, q ) 
		return HyperbolicQuadric(d, GF(q));
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  HermitianVariety( <d>, <f> )
# returns the standard hermitian variety. See CanonicalGramMatrix
# for details on the standard.
##
InstallMethod( HermitianVariety, 
	"for an integer and a field",	
	[ IsPosInt, IsField ],
	function( d, f )
		local h,m,types,max,reps,q;
		if PrimePowersInt(Size(f))[2] mod 2 <> 0 then
			Error("field order must be a square");
			return;
		fi;
		q := Sqrt(Size(f));
		m := CanonicalGramMatrix("hermitian", d+1, f);   
		h := PolarSpaceStandard( HermitianFormByMatrix(m, f) );
		if d mod 2 = 0 then  
			SetRankAttr( h, d/2 );
		else
			SetRankAttr( h, (d+1)/2 );    
		fi;    
		types := TypesOfElementsOfIncidenceStructure( AmbientSpace(h) );
		SetTypesOfElementsOfIncidenceStructure(h, types{[1..RankAttr(h)]});
		SetIsHermitianVariety(h, true);
		SetIsCanonicalPolarSpace(h, true);
		SetPolarSpaceType(h, "hermitian");
		if RankAttr(h) = 2 then
			if d = 3 then SetOrder( h, [q^2, q]); fi;
			if d = 4 then SetOrder( h, [q^2, q^3]); fi;
		fi;
		max := CanonicalOrbitRepresentativeForSubspaces("hermitian", d+1, f)[1];

    ## Here we take the maximal totally isotropic subspace rep
    ## max and make representatives for lower dimensional subspaces
		reps := [ max[1] ];
		Append(reps, List([2..RankAttr(h)], j -> max{[1..j]}));  

    ## We would like the representative to be stored as
    ## compressed matrices. Then they will be more efficient
    ## to work with.
		for m in reps do
			if IsMatrix(m) then
				ConvertToMatrixRep(m,f);
			else
				ConvertToVectorRep(m,f);  
			fi;
		od;   

    ## Wrap 'em up
		reps := List([1..RankAttr(h)], j -> Wrap(h, j, reps[j]) );
		SetRepresentativesOfElements(h, reps);
		SetClassicalGroupInfo( h, rec(  degree := (q^d-(-1)^d)*(q^(d+1)-(-1)^(d+1))/(q^2-1)) );
		return h;
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  HermitianVariety( <d>, <q> )
# returns the standard hermitian variety. See HermitianVariety method above.
##
InstallMethod(HermitianVariety,
	"for an two integers",
	[ IsPosInt, IsPosInt ],
	function( d, q ) 
		return HermitianVariety(d, GF(q));
	end );

#############################################################################
# methods for some attributes.
#############################################################################

# CHECKED 20/09/11 jdb
#############################################################################
#O  UnderlyingVectorSpace( <ps> )
# returns the Underlying vectorspace of the polar space <ps>
##
InstallMethod( UnderlyingVectorSpace, 
	"for a polar space",
	[IsClassicalPolarSpace and IsClassicalPolarSpaceRep],
	function(ps)
		return ShallowCopy(ps!.vectorspace);
	end);

# CHECKED 20/09/11 jdb
#############################################################################
#A  ProjectiveDimension( <ps> )
# returns the projective dimension of the polar space <ps>, i.e. the dimension
# of the ambient projective space.
##
InstallMethod( ProjectiveDimension, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		return ps!.dimension;  
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#A  Dimension( <ps> )
# returns the projective dimension of the polar space <ps>, i.e. the dimension
# of the ambient projective space.
##
InstallOtherMethod( Dimension, 
	"for a polar space",
	[ IsClassicalPolarSpace ],
	function(ps)
		return Dimension(AmbientSpace(ps));
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#A  PolarSpaceType( <ps> )
# type of a polar space: see manual and conventions for orthogonal polar spaces.
##
InstallMethod( PolarSpaceType, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local ty, form, sesq;
		if HasQuadraticForm( ps ) then 
			form := QuadraticForm( ps );
		else 
			form := SesquilinearForm( ps );
		fi;
		ty := form!.type;
		if ty = "orthogonal" or ty = "quadratic" then
			if IsParabolicForm( form ) then
				ty := "parabolic";
			elif IsEllipticForm( form ) then
				ty := "elliptic";
			else
				ty := "hyperbolic";
			fi;
		fi;
		return ty;
	end );

# CHECKED 20/09/11 jdb
#############################################################################
#A  CompanionAutomorphism( <ps> )
# companion automorphism of polar space, i.e. the companion automorphism of 
# the sesquilinear form determining the polar space. If the form is quadratic, 
# or not hermitian, then the trivial automorphism is returned.
##
InstallMethod( CompanionAutomorphism, 
	"for a polar space",
	[ IsClassicalPolarSpace ],
	function( ps )
		local aut, type;
		type := PolarSpaceType( ps );
		aut := FrobeniusAutomorphism(ps!.basefield);
		if type = "hermitian" then
			aut := aut ^ (Order(aut)/2);
		else
			aut := aut ^ 0;
		fi;
		return aut;
	end );

#############################################################################
# jdb and ml will change ViewObj/PrintObj/Display methods now.
#############################################################################

InstallMethod( ViewObj, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( p )
		Print("<polar space over ",p!.basefield,">");
	end );

InstallMethod( ViewObj,
	"for an elliptic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsEllipticQuadric],
	function( p )
		Print("Q-(",p!.dimension,", ",Size(p!.basefield),")");
	end );

InstallMethod( ViewObj,
	"for a standard elliptic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsEllipticQuadric and IsStandardPolarSpace],
	function( p )
		Print("standard Q-(",p!.dimension,", ",Size(p!.basefield),")");
	end );

InstallMethod( ViewObj,
	"for a symplectic space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsSymplecticSpace],
    function( p )
		Print("W(",p!.dimension,", ",Size(p!.basefield),")");
	end );

InstallMethod( ViewObj,
	"for a standard symplectic space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsSymplecticSpace and IsStandardPolarSpace],
    function( p )
		Print("standard W(",p!.dimension,", ",Size(p!.basefield),")");
	end );

InstallMethod( ViewObj,
	"for a parabolic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsParabolicQuadric ],
    function( p )
		Print("Q(",p!.dimension,", ",Size(p!.basefield),")");
	end);

InstallMethod( ViewObj,
	"for a standard parabolic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsParabolicQuadric and IsStandardPolarSpace ],
    function( p )
		Print("standard Q(",p!.dimension,", ",Size(p!.basefield),")");
	end);

InstallMethod( ViewObj,
	"for a hyperbolic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHyperbolicQuadric ],
    function( p )
		Print("Q+(",p!.dimension,", ",Size(p!.basefield),")");
	end);

InstallMethod( ViewObj,
	"for a standard hyperbolic quadric",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHyperbolicQuadric and IsStandardPolarSpace],
    function( p )
		Print("standard Q+(",p!.dimension,", ",Size(p!.basefield),")");
	end);

InstallMethod( ViewObj,
	"for a hermitian variety",
	[IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHermitianVariety ],
    function( p )
		Print("H(",p!.dimension,", ",Sqrt(Size(p!.basefield)),"^2)");
	end);

InstallMethod( ViewObj,
	"for a standard hermitian variety",
	[IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHermitianVariety ],
    function( p )
		Print("standard H(",p!.dimension,", ",Sqrt(Size(p!.basefield)),"^2)");
    end);

InstallMethod( PrintObj, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( p )
    Print("PolarSpace(\n");
    if HasQuadraticForm(p) then
       Print(QuadraticForm(p));
    else
       Print(SesquilinearForm(p));
    fi;
    Print(", ", p!.basefield, " )");
  end );

InstallMethod( Display, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( p )
    Print("<polar space of rank ",p!.dimension," over ",p!.basefield,">\n");
    if HasQuadraticForm(p) then
       Display(QuadraticForm(p));
    fi;
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

InstallMethod( PrintObj,
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsEllipticQuadric ],
        function( p )
          Print("EllipticQuadric(",p!.dimension,",",p!.basefield,")");
        end );

InstallMethod( Display, 
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsEllipticQuadric ],
  function( p )
    Print("Q-(",p!.dimension,", ",Size(p!.basefield),")\n");
    if HasQuadraticForm(p) then
       Display(QuadraticForm(p));
    fi;
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

InstallMethod( PrintObj,
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsSymplecticSpace ],
        function( p )
          Print("SymplecticSpace(",p!.dimension,",",p!.basefield,")");
  end);

InstallMethod( Display, 
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsSymplecticSpace ],
  function( p )
    Print("W(",p!.dimension,", ",Size(p!.basefield),")\n");
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

InstallMethod( PrintObj,
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsParabolicQuadric ],
        function( p )
          Print("ParabolicQuadric(",p!.dimension,",",p!.basefield,")");
  end);

InstallMethod( Display, 
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsParabolicQuadric ],
  function( p )
    Print("Q(",p!.dimension,", ",Size(p!.basefield),")\n");
    if HasQuadraticForm(p) then
       Display(QuadraticForm(p));
    fi;
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

InstallMethod( PrintObj,
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHyperbolicQuadric ],
        function( p )
          Print("HyperbolicQuadric(",p!.dimension,",",p!.basefield,")");
        end);

InstallMethod( Display, 
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHyperbolicQuadric ],
  function( p )
    Print("Q+(",p!.dimension,", ",Size(p!.basefield),")\n");
    if HasQuadraticForm(p) then
       Display(QuadraticForm(p));
    fi;
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

InstallMethod( PrintObj,
  [IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHermitianVariety ],
        function( p )
          Print("HermitianVariety(",p!.dimension,",",p!.basefield,")");
        end);

InstallMethod( Display, 
  [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep and IsHermitianVariety ],
  function( p )
    Print("H(",p!.dimension,", ",Size(p!.basefield),")\n");
    Display(SesquilinearForm(p));
    if HasDiagramOfGeometry( p ) then
       Display( DiagramOfGeometry( p ) );
    fi;
  end );

#############################################################################
## The following methods are needed for "naked" polar spaces; those
## that on conception are devoid of many of the attributes that
## the "canonical" polar spaces exhibit (see the code for the
## "SymplecticSpace" as an example).
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  IsomorphismCanonicalPolarSpace( <ps> )
# This method returns a geometry morphism that is in fact the coordinate transformation
# going FROM the standard polar space TO the given polar space <ps>
##
InstallMethod( IsomorphismCanonicalPolarSpace, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local d, f, type, canonical, iso, info;
		d := ps!.dimension;
		f := ps!.basefield;
		type := PolarSpaceType( ps );
		if type = "hermitian" then
			canonical := HermitianVariety(d, f);               
			SetIsHermitianVariety(ps, true);            
		elif type = "symplectic" then
			canonical := SymplecticSpace(d, f);         
			SetIsSymplecticSpace(ps, true);
		elif type = "elliptic" then 
			canonical := EllipticQuadric(d, f);         
			SetIsEllipticQuadric(ps, true);
		elif type = "parabolic" then
			canonical := ParabolicQuadric(d, f);         
			SetIsParabolicQuadric(ps, true);
		elif type = "hyperbolic" then
			canonical := HyperbolicQuadric(d, f);         
			SetIsHyperbolicQuadric(ps, true);
		fi;
		iso := IsomorphismPolarSpacesNC(canonical, ps, false);      ## jb: no longer computes nice monomorphism here
		info := ClassicalGroupInfo( canonical );
		SetClassicalGroupInfo( ps, rec( degree := info!.degree ) );
		return iso;
	end );

#############################################################################
#O  IsomorphismCanonicalPolarSpaceWithIntertwiner( <ps> )
# This method returns a geometry morphism that is in fact the coordinate transformation
# going FROM the standard polar space TO the given polar space <ps>, with intertwiner
##
InstallMethod( IsomorphismCanonicalPolarSpaceWithIntertwiner, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local d, f, type, canonical, iso, info;
		d := ps!.dimension;
		f := ps!.basefield;
		type := PolarSpaceType( ps );
		if type = "hermitian" then
			canonical := HermitianVariety(d, f);               
			SetIsHermitianVariety(ps, true);            
		elif type = "symplectic" then
			canonical := SymplecticSpace(d, f);         
			SetIsSymplecticSpace(ps, true);
		elif type = "elliptic" then 
			canonical := EllipticQuadric(d, f);         
			SetIsEllipticQuadric(ps, true);
		elif type = "parabolic" then
			canonical := ParabolicQuadric(d, f);         
			SetIsParabolicQuadric(ps, true);
		elif type = "hyperbolic" then
			canonical := HyperbolicQuadric(d, f);         
			SetIsHyperbolicQuadric(ps, true);
		fi;
		iso := IsomorphismPolarSpacesNC(canonical, ps, true); 
		info := ClassicalGroupInfo( canonical );
		SetClassicalGroupInfo( ps, rec( degree := info!.degree ) );
		return iso;
	end );

#############################################################################
## TOT HIER GECHECKT JDB en ML 15/04/11
#############################################################################

#############################################################################
#
#  Groups: (special) isometry groups and similarity group of finite classical
#           polar spaces
#
#############################################################################


InstallMethod( SpecialIsometryGroup, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( ps )
    local iso, twiner, g, info, coll, d, f, type;

    if HasIsCanonicalPolarSpace(ps) and IsCanonicalPolarSpace(ps) then
       type := PolarSpaceType( ps );
       info := ClassicalGroupInfo( ps );
       coll := CollineationGroup( ps );
       d := ps!.dimension + 1; 
       f := ps!.basefield;
       
       if type = "symplectic" then
          g := Spdesargues(d,f);
       elif type = "elliptic" then
          g := SOdesargues(-1,d,f);
       elif type = "hyperbolic" then
          g := SOdesargues(1,d,f);
       elif type = "parabolic" then
          g := SOdesargues(0,d,f);
       elif type = "hermitian" then
          g := SUdesargues(d, f);
       fi;
      
       SetParent(g, coll);
    else
       iso := IsomorphismCanonicalPolarSpaceWithIntertwiner( ps );
       twiner := Intertwiner( iso );
       g := Image(twiner, SpecialIsometryGroup(Source(iso)!.geometry) );
       SetParent(g, CollineationGroup(ps));
    fi;
    return g;
  end );

InstallMethod( IsometryGroup, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( ps )
    local iso, twiner, g, info, coll, d, f, type;

    if HasIsCanonicalPolarSpace(ps) and IsCanonicalPolarSpace(ps) then
       type := PolarSpaceType( ps );
       info := ClassicalGroupInfo( ps );
       coll := CollineationGroup( ps );
       d := ps!.dimension + 1; 
       f := ps!.basefield;
       
       if type = "symplectic" then
          g := Spdesargues(d,f);
       elif type = "elliptic" then
          g := GOdesargues(-1,d,f);
       elif type = "hyperbolic" then
          g := GOdesargues(1,d,f);
       elif type = "parabolic" then
          g := GOdesargues(0,d,f);
       elif type = "hermitian" then
          g := GUdesargues(d, f);
       fi;
      
       SetParent(g, coll);
    else
       
       iso := IsomorphismCanonicalPolarSpaceWithIntertwiner( ps );

       twiner := Intertwiner( iso );
       g := Image(twiner, IsometryGroup(Source(iso)!.geometry) );
       SetParent(g, CollineationGroup(ps));
    fi;
    return g;
  end );

InstallMethod( SimilarityGroup, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( ps )
    local iso, twiner, g, info, coll, d, f, type;
    if HasIsCanonicalPolarSpace(ps) and IsCanonicalPolarSpace(ps) then
       type := PolarSpaceType( ps );
       info := ClassicalGroupInfo( ps );
       coll := CollineationGroup( ps );
       d := ps!.dimension + 1; 
       f := ps!.basefield;
       
       if type = "symplectic" then
          g := GSpdesargues(d,f);
       elif type = "elliptic" then
          g := DeltaOminus(d,f);
       elif type = "hyperbolic" then
          g := DeltaOplus(d,f);
       elif type = "parabolic" then
          g := GOdesargues(0,d,f);
       elif type = "hermitian" then
          g := GUdesargues(d, f);
       fi;
      
       SetParent(g, coll);
    else
      iso := IsomorphismCanonicalPolarSpaceWithIntertwiner( ps );
      twiner := Intertwiner( iso );
      g := Image(twiner, SimilarityGroup(Source(iso)!.geometry) );
      SetParent(g, CollineationGroup(ps));
    fi;
    return g;
  end );

InstallMethod( CollineationGroup, [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
  function( ps )
    local iso, twiner, g, info, x, points, hom, d, f, coll, type;
    d := ps!.dimension + 1; 
    f := ps!.basefield;

    if HasIsCanonicalPolarSpace(ps) and IsCanonicalPolarSpace(ps) then
       type := PolarSpaceType( ps );
       info := ClassicalGroupInfo( ps );
             
       if type = "symplectic" then
          g := GammaSp(d,f);
       elif type = "elliptic" then
          g := GammaOminus(d,f);  
       elif type = "hyperbolic" then
          g := GammaOplus(d,f);
       elif type = "parabolic" then
          g := GammaO(d,f);
       elif type = "hermitian" then
          g := GammaU(d, f);
       fi;
       
    else    
       iso := IsomorphismCanonicalPolarSpaceWithIntertwiner( ps );
       Info(InfoFinInG, 1, "Computing collineation group of canonical polar space...");
       coll := CollineationGroup( Source(iso)!.geometry );
       info := ClassicalGroupInfo( ps );
       twiner := Intertwiner( iso );           
       g := Image(twiner, coll);
    fi;
    
    ## Setting up the NiceMonomorphism

    Info(InfoFinInG, 1, "Computing nice monomorphism...");
    x := RepresentativesOfElements( ps )[1];   
    if DESARGUES.Fast then
       hom := NiceMonomorphismByOrbit( g, x!.obj, OnProjPointsWithFrob, info!.degree);
    else 
       points := Orbit(g, x, OnProjSubspaces);
       hom := ActionHomomorphism(g, points, OnProjSubspaces, "surjective");    
       SetIsBijective(hom, true);
       SetNiceObject(g, Image(hom) );
    fi;
    SetNiceMonomorphism(g, hom );
    
    return g;
  end );

#############################################################################


#############################################################################
#More attributes...
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  RankAttr( <ps> )
# returns the rank of the polar space <ps>, which is the Witt index of the
# defining form.
##
InstallMethod( RankAttr,
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local iso;
		iso := IsomorphismCanonicalPolarSpace( ps );
		return RankAttr(Source(iso)!.geometry);
  end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  TypesOfElementsOfIncidenceStructure( <ps> )
# Well known method that returns a list with the names of the elements of 
# the polar space <ps>
##
InstallMethod( TypesOfElementsOfIncidenceStructure, 
	"for a polar space (line 1375)",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local iso;
		iso := IsomorphismCanonicalPolarSpace( ps );
		return TypesOfElementsOfIncidenceStructure(Source(iso)!.geometry);
	end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  Order( <ps> )
# If <ps> has rank two, then it is a GQ, and we can ask its order.
##
InstallOtherMethod( Order, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		if RankAttr(ps) = 2 then
			return Order(Source(IsomorphismCanonicalPolarSpace(ps) )!.geometry );
		else
			Error("Rank is not 2");
		fi;
	end );
  
# CHECKED 21/09/11 jdb
#############################################################################
#O  RepresentativesOfElements( <ps> )
# If <ps> has rank two, then it is a GQ, and we can ask its order.
##
InstallMethod( RepresentativesOfElements, 
	"for a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep ],
	function( ps )
		local iso, reps;
		iso := IsomorphismCanonicalPolarSpace( ps );
		reps := RepresentativesOfElements( Source( iso )!.geometry );
		return ImagesSet(iso, reps);
	end );

#############################################################################
# one more operation...
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  \QUO( <ps>, <v> )
# returns the quotien space of the element <v>, which must be an element of the
# polar space <ps>
##
InstallOtherMethod(\QUO,  
	"for a polar space and an element of a polar space",
	[ IsClassicalPolarSpace and IsClassicalPolarSpaceRep, IsSubspaceOfClassicalPolarSpace],
	function( ps, v )
		if not v in ps then 
			Error( "Subspace does not belong to the polar space" );
		fi;
		return Range( NaturalProjectionBySubspace( ps, v ) )!.geometry;
	end );

#############################################################################
# Counting the number of elements of the polar spaces
#############################################################################

# CHECKED 21/09/11 jdb
#############################################################################
#O  Size( <vs> )
# returns the number of elements on <vs>, a collection of elements of a polar
# space of a given type.
##
InstallMethod( Size, 
	"for a collection of elements of a polar space",
	[IsSubspacesOfClassicalPolarSpace],
	function( vs )
		local geom, q, d, m, ovnum, ordominus, numti, gauss, flavour;
		geom := vs!.geometry; 
		q := Size(vs!.geometry!.basefield);
		d := vs!.geometry!.dimension + 1;
		m := vs!.type;
		flavour := PolarSpaceType(geom);
        if flavour = "symplectic" then
			return Product(List([0..(m-1)],i->(q^(d-2*i)-1)/(q^(i+1)-1)));
		fi;
		if flavour = "elliptic" then
			gauss:=Product(List([0..(m-1)],i->(q^(d/2-1)-q^i)/(q^m-q^i)));
			numti:=gauss * Product(List([0..(m-1)],j->q^(d/2-j)+1));
			return numti;
		fi;
		if flavour = "hyperbolic" then
			gauss:=Product(List([0..(m-1)],i->(q^(d/2)-q^i)/(q^m-q^i)));
			numti:=gauss * Product(List([0..(m-1)],j->q^(d/2-1-j)+1));
			return numti;
		fi;
		if flavour = "parabolic" then
			gauss:=Product(List([0..(m-1)],i->(q^((d-1)/2)-q^i)/(q^m-q^i)));
			numti:=gauss * Product(List([0..(m-1)],j->q^( (d+1)/2-1-j)+1));
			return numti;
		fi;
		if flavour = "hermitian" then
			return Product(List([(d+1-2*m)..d],i->(Sqrt(q)^i-(-1)^i)))/
			Product(List([1..m],j->q^j-1 ));
		fi;
		Error("Unknown polar space type!");
	end );

#############################################################################
# Elements -- Subspaces
#############################################################################

## The following needs more work: I think it's ok now. jdb
## jb 19/02/2009: Just changed the compressed matrix methods
##               so that length 1 matrices are allowed.

# CHECKED 21/09/11 jdb
#############################################################################
#O  VectorSpaceToElement( <geom>, <v> ) returns the elements in <geom> determined
# by the vectorspace <v>. Several checks are built in. 
##
InstallMethod( VectorSpaceToElement, 
	"for a polar space and a Plist",
	[IsClassicalPolarSpace, IsPlistRep],
	function( geom, v )
		local  x, n, i;
		## when v is empty... 
		if IsEmpty(v) then
			Error("<v> does not represent any element");
		fi;
		x := MutableCopyMat(v);
		TriangulizeMat(x);
		## dimension should be correct
		if Length(v[1]) <> geom!.dimension + 1 then
			Error("Dimensions are incompatible");
		fi;
		## Remove zero rows. It is possible the the user
		## has inputted a matrix which does not have full rank
        n := Length(x);
		i := 0;
		while i < n and ForAll(x[n-i], IsZero) do
			i := i+1; 
		od;
		if i = n then
			return EmptySubspace(geom);
		fi;
		x := x{[1..n-i]};
		#if we check later on the the subspace is an element of the polar space, then
		#the user cannot create the whole polar space like this, so I commented out the
		# next three lines.
		#if Length(x)=ProjectiveDimension(geom)+1 then
		#	return geom;
		#fi;
        ## check here that it is in the polar space. 
		if HasQuadraticForm(geom) then
			if not IsTotallySingularSubspace(QuadraticForm(geom),x) then
			Error("<x> does not generate an element of <geom>");
			fi;
		else
			if not IsTotallyIsotropicSubspace(SesquilinearForm(geom),x) then
				Error("<x> does not generate an element of <geom>");
			fi;
		fi;
		if Length(x) = 1 then
			x := x[1];
			ConvertToVectorRep(x, geom!.basefield); # the extra basefield is necessary.
			return Wrap(geom, 1, x[1]);
		else
			ConvertToMatrixRep(x, geom!.basefield);
			return Wrap(geom, Length(x), x);
		fi;
	end );

# CHECKED 21/09/11
#############################################################################
#O  VectorSpaceToElement( <geom>, <v> ) returns the elements in <geom> determined
# by the vectorspace <v>. Several checks are built in. 
##
InstallMethod( VectorSpaceToElement,	
	"for a compressed GF(2)-matrix",
	[IsClassicalPolarSpace, IsGF2MatrixRep],
	function( geom, v )
		local  x, n, i;
		if IsEmpty(v) then
			Error("<v> does not represent any element");
		fi;
		x := MutableCopyMat(v);
		TriangulizeMat(x);
		## remove zero rows
		n := Length(x);
		i := 0;
		while i < n and ForAll(x[n-i], IsZero) do
			i := i+1; 
		od;
		if i = n then
			return EmptySubspace(geom);
		fi;
		x := x{[1..n-i]};
		x := x{[1..n-i]};
		#if we check later on the the subspace is an element of the polar space, then
		#the user cannot create the whole polar space like this, so I commented out the
		# next three lines.
		#if Length(x)=ProjectiveDimension(geom)+1 then
		#	return geom;
		#fi;
        ## check here that it is in the polar space. 
		if HasQuadraticForm(geom) then
			if not IsTotallySingularSubspace(QuadraticForm(geom),x) then
				Error("<x> does not generate an element of <geom>");
			fi;
		else
			if not IsTotallyIsotropicSubspace(SesquilinearForm(geom),x) then
				Error("<x> does not generate an element of <geom>");
			fi;
		fi;
		if Length(x) = 1 then
			x := x[1];
			if not IsGF2VectorRep(x) then
				ConvertToVectorRep(x, geom!.basefield);
			fi;
			return Wrap(geom, 1, x);
		else
			return Wrap(geom, Length(x), ImmutableMatrix(geom!.basefield, x));
		fi;
		#return Wrap(geom, Length(v), x); ??? why was this line? jdb.
  end );
  
# CHECKED 21/09/11
#############################################################################
#O  VectorSpaceToElement( <geom>, <v> ) returns the elements in <geom> determined
# by the vectorspace <v>. Several checks are built in. 
##
InstallMethod( VectorSpaceToElement, 
	"for a compressed basis of a vector subspace",
	[IsClassicalPolarSpace, Is8BitMatrixRep],
	function( geom, v )
		local  x, n, i; 
		if IsEmpty(v) then
			Error("<v> does not represent any element");
		fi;
		x := MutableCopyMat(v);
		TriangulizeMat(x);
	## dimension should be correct
		if Length(v[1]) <> geom!.dimension + 1 then
			Error("Dimensions are incompatible");
		fi;	
	## remove zero rows
		n := Length(x);
		i := 0;
		while i < n and ForAll(x[n-i], IsZero) do
			i := i+1; 
		od;
		if i = n then
			return EmptySubspace(geom);
		fi;
		x := x{[1..n-i]};
		#if we check later on the the subspace is an element of the polar space, then
		#the user cannot create the whole polar space like this, so I commented out the
		# next three lines.
		#if Length(x)=ProjectiveDimension(geom)+1 then
		#	return geom;
		#fi;
      
		## check here that it is in the polar space. 
		if HasQuadraticForm(geom) then
			if not IsTotallySingularSubspace(QuadraticForm(geom),x) then
				Error("<x> does not generate an element of <geom>");
			fi;
		else
			if not IsTotallyIsotropicSubspace(SesquilinearForm(geom),x) then
				Error("<x> does not generate an element of <geom>");
			fi;
		fi;
		if Length(x) = 1 then
		x := x[1];
		if not Is8BitVectorRep(x) then
            ConvertToVectorRep(x, geom!.basefield);
		fi;
		return Wrap(geom, 1, x);
		else
			return Wrap(geom, Length(x), ImmutableMatrix(geom!.basefield, x));
      fi;
    #return Wrap(geom, Length(v), x); ??? why was this line? jdb.
end );

# CHECKED 21/09/11 jdb
#############################################################################
#O  VectorSpaceToElement( <geom>, <v> ) returns the elements in <geom> determined
# by the rowvector <v>. Several checks are built in.
##
InstallMethod( VectorSpaceToElement, 
	"for a row vector",
	[IsClassicalPolarSpace, IsRowVector],
	function( geom, v )
		local  x;
		## dimension should be correct
		if Length(v) <> geom!.dimension + 1 then
			Error("Dimensions are incompatible");
		fi;
		x := ShallowCopy(v);
		if IsZero(x) then
			return EmptySubspace(geom);
		else
			if HasQuadraticForm(geom) then
				if not IsIsotropicVector(QuadraticForm(geom),x) then
					Error("<v> does not generate an element of <geom>");
				fi;
			else
				if not IsIsotropicVector(SesquilinearForm(geom),x) then
					Error("<v> does not generate an element of <geom>");
				fi;
			fi;
			MultRowVector(x,Inverse( x[PositionNonZero(x)] ));
			ConvertToVectorRep(x, geom!.basefield);
			return Wrap(geom, 1, x);
		fi;
  end );
  
#############################################################################
#O  VectorSpaceToElement( <geom>, <v> ) returns the elements in <geom> determined
# by the rowvector <v>. Several checks are built in.
##
InstallMethod( VectorSpaceToElement, 
	"for a polar space and an 8-bit vector",
  [IsClassicalPolarSpace, Is8BitVectorRep],
  function( geom, vec )
    local  c, gf;
      if IsZero(vec) then
         return [];
      fi;
      gf := BaseField(vec);
      c := PositionNonZero( vec );
      if c <= Length( vec )  then
         vec := Inverse( vec[c] ) * vec;
         ConvertToVectorRep( vec, gf );
      fi;
      return Wrap(geom, 1, vec);
  end );

InstallMethod( TypesOfElementsOfIncidenceStructure, "for a polar space", 
  [IsClassicalPolarSpace],
  function( ps )
    local d,i,types;
    types := ["point"];
    d := ProjectiveDimension(ps);
    if d >= 2 then Add(types,"line"); fi;
    if d >= 3 then Add(types,"plane"); fi;
    if d >= 4 then Add(types,"solid"); fi;
    for i in [5..d] do
        Add(types,Concatenation("proj. subspace of dim. ",String(i-1)));
    od;
    return types;
  end );

InstallMethod( TypesOfElementsOfIncidenceStructurePlural, "for a polar space",
  [IsClassicalPolarSpace],
  function( ps )
    local d,i,types;
    types := ["points"];
    d := ProjectiveDimension(ps);
    if d >= 2 then Add(types,"lines"); fi;
    if d >= 3 then Add(types,"planes"); fi;
    if d >= 4 then Add(types,"solids"); fi;
    for i in [5..d] do
        Add(types,Concatenation("proj. subspaces of dim. ",String(i-1)));
    od;
    return types;
  end );


#I changed this, I now use the built in functions of forms to perform the test.
#jdb 6/1/8
InstallMethod( \in, "for a variety and a polar space",
  [IsElementOfIncidenceStructure, IsClassicalPolarSpace],
  function( w, ps )
    local form, r, ti;
    # if the vector spaces don't agree we can't go any further
    if w!.geo!.dimension <> ps!.dimension or
       not IsSubset(ps!.basefield, w!.geo!.basefield) then
       return false;
    fi;

    r := w!.obj;
    if w!.type = 1 then r := [r]; fi;

    # check if the subspace is totally isotropic/singular

    if HasQuadraticForm(ps) then
       form := QuadraticForm(ps);
       ti := IsTotallySingularSubspace(form,r);
    else
       form := SesquilinearForm(ps);
       ti:= IsTotallyIsotropicSubspace(form,r); 
    fi;
    
    # if yes, make it an element of the polar space.
    
    if not IsSubspaceOfClassicalPolarSpace(w) and ti then
       w!.geo := ps;
    fi;
    return ti;
  end );


InstallMethod(Iterator,  "for subspaces of a polar space",
        [IsSubspacesOfClassicalPolarSpace],
        function( vs )
          local ps, j, d, F, ty, v, ispolar;    
          ps := vs!.geometry;
          j := vs!.type;
          d := ps!.dimension;
          F := ps!.basefield;
          ty := SesquilinearForm(ps)!.type;
     
          if IsEvenInt(Size(F)) and 
             (ty = "elliptic" or ty = "parabolic" or ty = "hyperbolic") then
             ispolar := x -> IsTotallySingular(ps, x);
          else
             ispolar := x -> IsTotallyIsotropic(ps, x);
          fi;

          return IteratorByFunctions( rec(
            NextIterator := function(iter)
              local mat;

              iter!.returnednumber := iter!.returnednumber + 1;

              # use the subspace iterator to find the next
              # totally isotropic/singular subspace.
              repeat
                mat := BasisVectors(Basis(NextIterator(iter!.S)));
                if j = 1 then
                  v := Wrap(ps, j, mat[1]);
                else
                  v := Wrap(ps, j, mat);
                fi;
              until ispolar(v);    
              return v;
            end,
            IsDoneIterator := function(iter)
              return iter!.returnednumber = iter!.totalnumber;
            end,
            ShallowCopy := function(iter)
              return rec(
                S := ShallowCopy(iter!.S),
                geometry := iter!.geometry,
                form := iter!.form,
                # aut := iter!.aut,
                totalnumber := iter!.totalnumber,
                returnednumber := iter!.returnednumber
                );
            end,
            S := Iterator(Subspaces(ps!.vectorspace,j)),
            geometry := ps,
            form := SesquilinearForm(ps)!.matrix,
            totalnumber := Size(vs),
            returnednumber := 0
          ));
  end);

InstallMethod( NumberOfTotallySingularSubspaces, [IsClassicalPolarSpace, IsPosInt],
  function(ps, j)

  ## In a classical finit epolar space of rank r with parameters (q,q^e), 
  ## the number of subspaces of algebraic dimension j is given by
  ## [d, n] Prod_{i=1}^{n} (q^{r+e-i}+1)

    local r, d, type, e, q, qe;
    r := RankAttr(ps);
    d := ps!.dimension;
    type := PolarSpaceType(ps);
    q := Size(ps!.basefield); 

    if type = "elliptic" then e := 2; qe := q^e;
    elif type = "hyperbolic" then e:= 0; qe := q^e;
    elif type = "parabolic" or type = "symplectic" then e:=1; qe := q^e;
    elif type = "hermitian" and IsEvenInt(ps!.dimension) then e:=3; 
         qe := RootInt(q,2)^e;
    elif type = "hermitian" and IsOddInt(ps!.dimension) then e:=1; 
         qe := RootInt(q,2)^e;
    else Error("Polar space doesn't know its type!");
    fi;

    return Size(Subspaces(GF(q)^r, j)) * Product(List([1..j], i -> q^(r-i) * qe +1));
  end);

InstallMethod( ElementsOfIncidenceStructure, [IsClassicalPolarSpace, IsPosInt],
  function( ps, j )
    local r;
    r := Rank(ps);
    if j > r then
      Error("<geo> has no elements of type <j>");
    else
      return Objectify(
        NewType( ElementsCollFamily, IsSubspacesOfClassicalPolarSpace and
                                     IsSubspacesOfClassicalPolarSpaceRep ),
          rec(
            geometry := ps,
            type := j,
            size := NumberOfTotallySingularSubspaces(ps, j)
          )
        );
    fi;
  end);

InstallMethod( ElementsOfIncidenceStructure, [IsClassicalPolarSpace],
  function( ps )
    return Objectify(
      NewType( ElementsCollFamily, IsAllElementsOfIncidenceStructure ),
        rec( geometry := ps )
      );
  end);

InstallMethod( Points, [IsClassicalPolarSpace],
  function( ps )
    return ElementsOfIncidenceStructure(ps, 1);
  end);

InstallMethod( Lines, [IsClassicalPolarSpace],
  function( ps )
    return ElementsOfIncidenceStructure(ps, 2);
  end);

InstallMethod( Planes, [IsClassicalPolarSpace],
  function( ps )
    return ElementsOfIncidenceStructure(ps, 3);
  end);

InstallMethod( Solids, [IsClassicalPolarSpace],
  function( ps )
    return ElementsOfIncidenceStructure(ps, 4);
  end);

InstallMethod( TypeOfSubspace, 
     [ IsClassicalPolarSpace, IsSubspaceOfProjectiveSpace ],
  function( ps, w )
  
    ## At the moment, this is a helper operation, but perhaps
    ## it could be used by the user. This operation returns
    ## "degenerate", "hermitian", "symplectic", "elliptic",
    ## "hyperbolic", or "parabolic".
    
    local pstype, dim, type, mat, gf, q, form, newform;
    pstype := PolarSpaceType( ps );
    gf := ps!.basefield;             
    q := Size(gf);
    dim := w!.type;

    if pstype in ["elliptic", "parabolic", "hyperbolic"] and IsEvenInt(q) then
       form := QuadraticForm( ps );
       mat := w!.obj * form!.matrix * TransposedMat(w!.obj);
       newform := QuadraticFormByMatrix( mat, gf );

#  jdb makes a change here. it was 'IsDegenerateForm( newform )' but it is clear that we want to test whether
#  the quadratic form is *singular*, according to the definition in forms about degenerecy and singularity

       if IsSingularForm( newform ) then
          return "degenerate";    
       elif IsOddInt(dim) then
          return "parabolic";
       else
          if IsHyperbolicForm( newform ) then
             return "hyperbolic";
          else 
             return "elliptic";
          fi;
       fi;
    else
       form := SesquilinearForm( ps );
       mat := w!.obj * form!.matrix * TransposedMat(w!.obj);
       
       if pstype = "symplectic" then
          newform := BilinearFormByMatrix( mat, gf );
          if IsDegenerateForm( newform ) then
             return "degenerate";
          else
             return "symplectic";
          fi;
       elif pstype = "hermitian" then
          if IsHermitianMatrix( mat, gf ) then
             return "hermitian";
          else
             return "degenerate";
          fi;
       elif pstype in ["elliptic", "parabolic", "hyperbolic"] then
          newform := BilinearFormByMatrix( mat, gf );
          if IsDegenerateForm( newform ) then
             return "degenerate";
          else
             if IsEllipticForm(newform) then
                return "elliptic";
             elif IsHyperbolicForm(newform) then
                return "hyperbolic";
             else
                return "parabolic";
             fi;             
          fi;
       fi;
    fi;
    
    Print("Polar space does not have a recognisable type\n");
    return;
  end );


InstallMethod( RandomSubspace, "for a polar space and a dimension",
                       [ IsClassicalPolarSpace, IsPosInt ],                                             
  function( ps, d )
    local x, rep;
    x := PseudoRandom( CollineationGroup(ps) );
    rep := RepresentativesOfElements(ps)[d+1];    
    return OnProjSubspaces(rep, x);
  end );


InstallMethod( Random, "for a collection of subspaces of a polar space",
                       [ IsSubspacesOfClassicalPolarSpace ],
                       
  ## Since it is quick to find a pseudo-random element
  ## of a group (a random subproduct of the generators),
  ## we just find a random collineation and take the image
  ## of the associated element representative (see RepresentativesOfElements).
                       
  function( subs )
    local ps, x, rep;
    ps := subs!.geometry;
    x := PseudoRandom( CollineationGroup(ps) );
    rep := RepresentativesOfElements(ps)[subs!.type];    
    return OnProjSubspaces(rep, x);
  end );
  

#############################################################################
#
#   Shadows of elements and flags
#
#############################################################################

InstallMethod( ShadowOfElement, [IsClassicalPolarSpace, IsElementOfIncidenceStructure, IsPosInt],
  function( ps, v, j )
    local localinner, localouter, localfactorspace,
          pstype, psdim, f, vdim, sz;

    pstype := PolarSpaceType(ps);
    psdim := ps!.dimension;
    f := ps!.basefield;
    vdim := v!.type;  
    
    if j < vdim then
      localinner := [];
      localouter := v!.obj;
      if IsVector(localouter) and not IsMatrix(localouter) then
         localouter := [localouter]; 
      fi;
      ConvertToMatrixRep( localouter, f );
      localfactorspace := Subspace(ps!.vectorspace, localouter);
      sz := Size(Subspaces(localfactorspace, j));
    elif j = vdim then
      localinner := v!.obj;
      if IsVector(localinner) and not IsMatrix(localinner) then
         localinner := [localinner]; 
      fi;
      localouter := localinner;
      localfactorspace := TrivialSubspace(ps!.vectorspace);
      sz := 1;
    else  
      localinner := v!.obj;
      localouter := Polarity(ps)(v)!.obj;
      
      if pstype = "symplectic" then
         localfactorspace := SymplecticSpace( psdim- 2*vdim, f );
      elif pstype = "hermitian" then
         localfactorspace := HermitianVariety( psdim-2*vdim, f );
      elif pstype = "elliptic" then 
         localfactorspace := EllipticQuadric( psdim-2*vdim, f );
      elif pstype = "parabolic" then 
         localfactorspace := ParabolicQuadric( psdim-2*vdim, f );
      elif pstype = "hyperbolic" then 
         localfactorspace := HyperbolicQuadric( psdim-2*vdim, f );
      fi;    
      sz := Size(ElementsOfIncidenceStructure(localfactorspace, j - vdim)); 
    fi;
    
    return Objectify(
      NewType( ElementsCollFamily, IsElementsOfIncidenceStructure and
                                IsShadowSubspacesOfClassicalPolarSpace and
                                IsShadowSubspacesOfClassicalPolarSpaceRep),
        rec(
          geometry := ps,
          type := j,
          inner := localinner,
          outer := localouter,
          factorspace := localfactorspace,
          size := sz
        )
      );
  end );

InstallMethod( Size, [IsShadowSubspacesOfClassicalPolarSpace and
  IsShadowSubspacesOfClassicalPolarSpaceRep ],
  function( vs )
    return vs!.size;
  end);

#############################################################################
# Display methods:
#############################################################################




#############################################################################
# Basic methods:
#############################################################################

InstallMethod( Polarity,  [IsClassicalPolarSpace],
  function( ps )
    local perp, m, ty, f, form, bi;

## If we have only a quadratic form Q, then we must remember
## to use let the map b(v,w) := Q(v+w)-Q(v)-Q(w) be the polarisation of Q,
## and consider the polarity induced from this map. This can be computed using AssociatedBilinearForm (from package forms).

    form := SesquilinearForm(ps);
    m := form!.matrix;
    f := form!.basefield;
    ty := form!.type;

    if ty = "hermitian" then
       perp := function(v)
         local perpv, uv, rk, aut;
         aut := CompanionAutomorphism(ps);
         uv := v!.obj;
         if v!.type = 1 then uv := [uv]; fi; 
         perpv := MutableCopyMat(TriangulizedNullspaceMat( m * TransposedMat(uv)^aut )); 
         rk := Rank(perpv);   
         if rk = 1 then perpv := perpv[1]; fi;
         return Wrap(AmbientSpace(ps), rk, perpv);
       end;
    else
       if IsEvenInt(Size(f)) and 
          (ty = "elliptic" or ty = "hyperbolic" or ty = "parabolic") then
          ## recover bilinear form from quadratic form
          bi := m + TransposedMat(m);
       else 
          bi := m;
       fi;
       
       perp := function(v)
         local perpv, uv, rk;
         uv := v!.obj;
         if v!.type = 1 then uv := [uv]; fi; 
         perpv := MutableCopyMat(TriangulizedNullspaceMat( bi * TransposedMat(uv) )); 
         rk := Rank(perpv);   
         if rk = 1 then
            perpv := perpv[1]; 
            ConvertToVectorRep( perpv, f );
         else
            ConvertToMatrixRep( perpv, f );
         fi;
         return Wrap(AmbientSpace(ps), rk, perpv);
       end;
    fi;
    return perp; ## should we return a correlation here?
  end );

InstallMethod( IsTotallySingular, "for a projective variety w.r.t a polarity",  
              [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep, IsSubspaceOfProjectiveSpace ],
  function( ps, v )
    local uv, bi, f, ty, localaut, m, form, 
          flag, bsum, count1, count2;

## Suppose the polar space is defined by a quadratic form Q. Then
## a subspace of the ambient projective space is totally singular if
## it computes zero under Q. If we have only a sesquilinear form b, 
## then let the map b(v,v) take the role of Q. 

    form := SesquilinearForm(ps);
    m := form!.matrix;
    f := form!.basefield;
    ty := form!.type;
    uv := v!.obj;
    if v!.type = 1 then uv := [uv]; fi; 
    if ty = "hermitian" then 
       localaut := CompanionAutomorphism(ps);
       return IsZero( uv * m * (TransposedMat(uv)^localaut) );
    else

## A subspace with basis B is totally singular w.r.t the quadratic form 
## Q(v) = vMv^T if for all pairs b_i and b_j in B we have Q(b_i+b_j) = 0.

       # check first that everything in uv is t.s.
       
       flag := ForAll(uv, x -> IsZero(x * m * x));
       if v!.type > 1 and flag then

         ## just a shorter way to go through combinations
         count1 := 1; count2 := 2;
         repeat
           repeat 
             bsum := uv[count1]+uv[count2];
             flag := IsZero(bsum * m * bsum);
             count2 := count2 + 1;
           until flag or count2 > Length(uv);
           count1 := count1 + 1;
           count2 := count1 + 1;
         until flag or count1 >= Length(uv);
       fi;
       return flag;    
    fi;
  end );

InstallMethod( IsTotallyIsotropic, "for a projective variety w.r.t a polarity", 
             [ IsClassicalPolarSpace and IsClassicalPolarSpaceRep, IsSubspaceOfProjectiveSpace ],
  function( ps, v )
    local perp, perpv;
    perp := Polarity(ps);
    perpv := perp(v);
    return perpv!.type >= v!.type and v in perp(v);
  end );

InstallMethod( IsCollinear, "for points of a polar space", 
              [IsClassicalPolarSpace and IsClassicalPolarSpaceRep, IsElementOfIncidenceStructure, IsElementOfIncidenceStructure],
  function( ps, a, b )
    local m;
    m := SesquilinearForm(ps)!.matrix;
    return Unwrap(a)*m*Unwrap(b)=Zero(ps!.basefield);
  end);






#InstallMethod( DefiningPolarity, "for a polar space, if it is defined by a polarity",
#    [ IsClassicalPolarSpace ],
#  function( ps )
#    local f, q, type, form, polarity;
#    f := ps!.basefield;
#    q := Size(f);
#    type := PolarSpaceType( ps );
#    if type in ["elliptic", "hyperbolic", "parabolic"] and IsEvenInt(q) then
#        Error("This polar space is not defined by a polarity");
#    else
#       form := SesquilinearForm( ps );
#    fi;
#    polarity := PolarityOfProjectiveSpace( form );
#    return polarity;
#  end );
#

#InstallMethod( Polarisation, "for a quadratic form",
#  [ IsQuadraticForm ],
#  function( form )
#
#  ## This function returns the bilinear form obtained from a quadratic
#  ## form Q; that is, <u ,v> = Q(u + v) - Q(u) - Q(v).
#  ## This method will be replace by the new operation in "Forms"
#  # jdb: I commented out this function now, we can use AssociatedBilinearForm.
#  local gram, f;
#    gram := form!.matrix;
#    f := form!.basefield;
#    return BilinearFormByMatrix( gram + TransposedMat(gram), f);
#  end);
 
#InstallMethod( \in, "for a variety and a polar space",
#  [IsElementOfIncidenceStructure, IsClassicalPolarSpace],
#  function( w, ps )
#    local form, r, tsingular, mat, aut, polar;
#    # if the vector spaces don't agree we can't go any further
#    if w!.geo!.vectorspace <> ps!.vectorspace then
#      return false;
#    fi;
#
#    r := w!.obj;
#    if w!.type = 1 then r := [r]; fi;
#
#    # check if the subspace is totally isotropic/singular
#
#    if HasQuadraticForm(ps) then
#       form := QuadraticForm(ps);
#       
#       ## check that each basis element is singular
#       if not ForAll( r, i -> IsZero( i^form ) ) then
#          return false;  
#       fi;
#       
#       ## now look at all pairs of basis elements
#       ## under the associated bilinear form
#
#       polar := AssociatedBilinearForm( form );
#       tsingular := ForAll([1..Size(r)-1], i ->
#                      ForAll([i+1..Size(r)], j ->
#                        IsZero( [r[i],r[j]]^polar ) ) );
#    else
#       form := SesquilinearForm(ps);
#       mat := form!.matrix;
#       if form!.type = "hermitian" then
#          aut := CompanionAutomorphism( ps );
#          tsingular := IsZero( (r^aut) * mat * TransposedMat(r) );
#       else 
#          tsingular := IsZero( r * mat * TransposedMat(r) ); 
#       fi;
#    fi;
#   
#    if not IsSubspaceOfClassicalPolarSpace(w) and tsingular then
#       w!.geo := ps;
#    fi;
#    return tsingular;
#  end );

