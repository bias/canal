# Canal

## Overview
This is code based on a computation linguistics class project. The goal is to use computational linguistics tools to provide a research oreinted C static analysis tool.

## Flex & Bison core
The code uses a modified form of a public C99 ANSI specification.

## Macros
Macros, including includes, are expanded for the intermediated form inorder to resolve identifiers.

## Identifiers
C fails to be LR(1) because of a conflict with identifier and typedef-name (and enumeration-constant). In layman's terms in C an identifier can be resolved as an IDENTIFIER, TYPEDEF_NAME or ENUMERATION_CONSTANT depending on the previous code context. This makes C super annoying for what we want to do since we'll have to use multiple passes to resolve the issue and generate intermediate files that preserve the structure/stastics of the code while expanding all macros and includes.
