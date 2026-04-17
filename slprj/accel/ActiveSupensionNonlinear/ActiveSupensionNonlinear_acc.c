#include "__cf_ActiveSupensionNonlinear.h"
#include <math.h>
#include "ActiveSupensionNonlinear_acc.h"
#include "ActiveSupensionNonlinear_acc_private.h"
#include <stdio.h>
#include "simstruc.h"
#include "fixedpoint.h"
#define CodeFormat S-Function
#define AccDefine1 Accelerator_S-Function
static void mdlOutputs ( SimStruct * S , int_T tid ) { real_T ootylckmep ;
n3qi1whofz * _rtB ; loikxjbxjg * _rtP ; ew10rzwqr2 * _rtDW ; _rtDW = ( (
ew10rzwqr2 * ) ssGetRootDWork ( S ) ) ; _rtP = ( ( loikxjbxjg * )
ssGetDefaultParam ( S ) ) ; _rtB = ( ( n3qi1whofz * ) _ssGetBlockIO ( S ) ) ;
_rtB -> k1rk1ps0wv = ( ( f1xhd02yjc * ) ssGetContStates ( S ) ) -> fzcauwnpex
; _rtB -> bctgab40lf = ( ( f1xhd02yjc * ) ssGetContStates ( S ) ) ->
b3d0buleld ; _rtB -> dooafvrhhs = _rtB -> bctgab40lf - _rtB -> k1rk1ps0wv ;
ootylckmep = _rtP -> P_2 * _rtB -> dooafvrhhs ; ssCallAccelRunBlock ( S , 1 ,
0 , SS_CALL_MDL_OUTPUTS ) ; _rtB -> iikpz3xb53 = _rtP -> P_3 * _rtB ->
hdhtvivoxd + ootylckmep ; ssCallAccelRunBlock ( S , 2 , 7 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> pl5vvgyksg = ( ( f1xhd02yjc * )
ssGetContStates ( S ) ) -> gyiwwnvcz3 ; ssCallAccelRunBlock ( S , 2 , 9 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> kdwcyhqewc = ( ( f1xhd02yjc * )
ssGetContStates ( S ) ) -> k1bjtcyn3o ; ssCallAccelRunBlock ( S , 2 , 11 ,
SS_CALL_MDL_OUTPUTS ) ; _rtB -> lawztzabn4 = ssGetT ( S ) ;
ssCallAccelRunBlock ( S , 0 , 0 , SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock
( S , 2 , 14 , SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
ssCallAccelRunBlock ( S , 2 , 15 , SS_CALL_MDL_OUTPUTS ) ; }
ssCallAccelRunBlock ( S , 2 , 16 , SS_CALL_MDL_OUTPUTS ) ; if ( ssIsSampleHit
( S , 2 , 0 ) ) { ssCallAccelRunBlock ( S , 2 , 17 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 2 , 18 , SS_CALL_MDL_OUTPUTS ) ; } ootylckmep = (
_rtB -> kdwcyhqewc - _rtB -> pl5vvgyksg ) * _rtP -> P_6 ; if ( ssIsSampleHit
( S , 1 , 0 ) ) { _rtB -> bsdgbl3t1x = _rtP -> P_7 ; } _rtB -> n05m0v4u0e = (
( _rtB -> iikpz3xb53 + ootylckmep ) + _rtB -> bsdgbl3t1x ) * _rtP -> P_8 ; if
( ssIsSampleHit ( S , 2 , 0 ) ) { ssCallAccelRunBlock ( S , 2 , 24 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 2 , 25 ,
SS_CALL_MDL_OUTPUTS ) ; ssCallAccelRunBlock ( S , 2 , 26 ,
SS_CALL_MDL_OUTPUTS ) ; } _rtB -> h3s0x2nrnl = ( ( ( ( _rtB -> m1bkmwtvj1 -
_rtB -> bctgab40lf ) * _rtP -> P_9 - _rtB -> iikpz3xb53 ) - ootylckmep ) -
_rtB -> bsdgbl3t1x ) * _rtP -> P_10 ; if ( ssIsSampleHit ( S , 2 , 0 ) ) {
ssCallAccelRunBlock ( S , 2 , 31 , SS_CALL_MDL_OUTPUTS ) ;
ssCallAccelRunBlock ( S , 2 , 32 , SS_CALL_MDL_OUTPUTS ) ; } UNUSED_PARAMETER
( tid ) ; }
#define MDL_UPDATE
static void mdlUpdate ( SimStruct * S , int_T tid ) { n3qi1whofz * _rtB ;
loikxjbxjg * _rtP ; _rtP = ( ( loikxjbxjg * ) ssGetDefaultParam ( S ) ) ;
_rtB = ( ( n3qi1whofz * ) _ssGetBlockIO ( S ) ) ; UNUSED_PARAMETER ( tid ) ;
}
#define MDL_DERIVATIVES
static void mdlDerivatives ( SimStruct * S ) { n3qi1whofz * _rtB ; loikxjbxjg
* _rtP ; _rtP = ( ( loikxjbxjg * ) ssGetDefaultParam ( S ) ) ; _rtB = ( (
n3qi1whofz * ) _ssGetBlockIO ( S ) ) ; { ( ( pqmvzr1kvu * ) ssGetdX ( S ) )
-> fzcauwnpex = _rtB -> pl5vvgyksg ; } { ( ( pqmvzr1kvu * ) ssGetdX ( S ) )
-> b3d0buleld = _rtB -> kdwcyhqewc ; } { ( ( pqmvzr1kvu * ) ssGetdX ( S ) )
-> gyiwwnvcz3 = _rtB -> n05m0v4u0e ; } { ( ( pqmvzr1kvu * ) ssGetdX ( S ) )
-> k1bjtcyn3o = _rtB -> h3s0x2nrnl ; } } static void mdlInitializeSizes (
SimStruct * S ) { ssSetChecksumVal ( S , 0 , 3367410638U ) ; ssSetChecksumVal
( S , 1 , 362421966U ) ; ssSetChecksumVal ( S , 2 , 3339677687U ) ;
ssSetChecksumVal ( S , 3 , 579004674U ) ; { mxArray * slVerStructMat = NULL ;
mxArray * slStrMat = mxCreateString ( "simulink" ) ; char slVerChar [ 10 ] ;
int status = mexCallMATLAB ( 1 , & slVerStructMat , 1 , & slStrMat , "ver" )
; if ( status == 0 ) { mxArray * slVerMat = mxGetField ( slVerStructMat , 0 ,
"Version" ) ; if ( slVerMat == NULL ) { status = 1 ; } else { status =
mxGetString ( slVerMat , slVerChar , 10 ) ; } } mxDestroyArray ( slStrMat ) ;
mxDestroyArray ( slVerStructMat ) ; if ( ( status == 1 ) || ( strcmp (
slVerChar , "8.3" ) != 0 ) ) { return ; } } ssSetOptions ( S ,
SS_OPTION_EXCEPTION_FREE_CODE ) ; if ( ssGetSizeofDWork ( S ) != sizeof (
ew10rzwqr2 ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal DWork sizes do "
"not match for accelerator mex file." ) ; } if ( ssGetSizeofGlobalBlockIO ( S
) != sizeof ( n3qi1whofz ) ) { ssSetErrorStatus ( S ,
"Unexpected error: Internal BlockIO sizes do "
"not match for accelerator mex file." ) ; } { int ssSizeofParams ;
ssGetSizeofParams ( S , & ssSizeofParams ) ; if ( ssSizeofParams != sizeof (
loikxjbxjg ) ) { static char msg [ 256 ] ; sprintf ( msg ,
"Unexpected error: Internal Parameters sizes do "
"not match for accelerator mex file." ) ; } } _ssSetDefaultParam ( S , (
real_T * ) & o2iu0a2jke ) ; rt_InitInfAndNaN ( sizeof ( real_T ) ) ; } static
void mdlInitializeSampleTimes ( SimStruct * S ) { { SimStruct * childS ;
SysOutputFcn * callSysFcns ; childS = ssGetSFunction ( S , 0 ) ; callSysFcns
= ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ] = (
SysOutputFcn ) ( NULL ) ; childS = ssGetSFunction ( S , 1 ) ; callSysFcns =
ssGetCallSystemOutputFcnList ( childS ) ; callSysFcns [ 3 + 0 ] = (
SysOutputFcn ) ( NULL ) ; } } static void mdlTerminate ( SimStruct * S ) { }
#include "simulink.c"
