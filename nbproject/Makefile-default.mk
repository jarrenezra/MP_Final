#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Include project Makefile
ifeq "${IGNORE_LOCAL}" "TRUE"
# do not include local makefile. User is passing all local related variables already
else
include Makefile
# Include makefile containing local settings
ifeq "$(wildcard nbproject/Makefile-local-default.mk)" "nbproject/Makefile-local-default.mk"
include nbproject/Makefile-local-default.mk
endif
endif

# Environment
MKDIR=gnumkdir -p
RM=rm -f 
MV=mv 
CP=cp 

# Macros
CND_CONF=default
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
IMAGE_TYPE=debug
OUTPUT_SUFFIX=obj
DEBUGGABLE_SUFFIX=obj
FINAL_IMAGE=${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
else
IMAGE_TYPE=production
OUTPUT_SUFFIX=obj
DEBUGGABLE_SUFFIX=obj
FINAL_IMAGE=${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}
endif

ifeq ($(COMPARE_BUILD), true)
COMPARISON_BUILD=
else
COMPARISON_BUILD=
endif

# Object Directory
OBJECTDIR=build/${CND_CONF}/${IMAGE_TYPE}

# Distribution Directory
DISTDIR=dist/${CND_CONF}/${IMAGE_TYPE}

# Source Files Quoted if spaced
SOURCEFILES_QUOTED_IF_SPACED=usart_motors1.asm

# Object Files Quoted if spaced
OBJECTFILES_QUOTED_IF_SPACED=${OBJECTDIR}/usart_motors1.obj
POSSIBLE_DEPFILES=${OBJECTDIR}/usart_motors1.obj.d

# Object Files
OBJECTFILES=${OBJECTDIR}/usart_motors1.obj

# Source Files
SOURCEFILES=usart_motors1.asm

# Pack Options 
PACK_ASSEMBLER_OPTIONS=-I "${DFP_DIR}/avrasm/inc"  -i AVR64DU32def.inc



CFLAGS=
ASFLAGS=
LDLIBSOPTIONS=

############# Tool locations ##########################################
# If you copy a project from one host to another, the path where the  #
# compiler is installed may be different.                             #
# If you open this project with MPLAB X in the new host, this         #
# makefile will be regenerated and the paths will be corrected.       #
#######################################################################
# fixDeps replaces a bunch of sed/cat/printf statements that slow down the build
FIXDEPS=fixDeps

.build-conf:  ${BUILD_SUBPROJECTS}
ifneq ($(INFORMATION_MESSAGE), )
	@echo $(INFORMATION_MESSAGE)
endif
	${MAKE}  -f nbproject/Makefile-default.mk ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}

# ------------------------------------------------------------------------------------
# Rules for buildStep: assemble
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${OBJECTDIR}/usart_motors1.obj: usart_motors1.asm  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} ${DISTDIR} 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/usart_motors1.obj 
	${MP_AS}  -fI -W+ie ${PACK_ASSEMBLER_OPTIONS} -d ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  -m ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.map  -S ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.tmp usart_motors1.asm
else
${OBJECTDIR}/usart_motors1.obj: usart_motors1.asm  nbproject/Makefile-${CND_CONF}.mk 
	@${MKDIR} ${DISTDIR} 
	@${MKDIR} "${OBJECTDIR}" 
	@${RM} ${OBJECTDIR}/usart_motors1.obj 
	${MP_AS}  -fI -W+ie ${PACK_ASSEMBLER_OPTIONS} -d ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${DEBUGGABLE_SUFFIX}  -S ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.tmp  -o ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.hex  -m ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.map  -l ${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.lss usart_motors1.asm
endif

# ------------------------------------------------------------------------------------
# Rules for buildStep: link
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk    
	
else
${DISTDIR}/goofy-ass-robot.X.${IMAGE_TYPE}.${OUTPUT_SUFFIX}: ${OBJECTFILES}  nbproject/Makefile-${CND_CONF}.mk   
	
endif


# Subprojects
.build-subprojects:


# Subprojects
.clean-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r ${OBJECTDIR}
	${RM} -r ${DISTDIR}

# Enable dependency checking
.dep.inc: .depcheck-impl

DEPFILES=$(wildcard ${POSSIBLE_DEPFILES})
ifneq (${DEPFILES},)
include ${DEPFILES}
endif
