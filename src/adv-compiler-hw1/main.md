---
title: Homework 1 - Data Depndency LLVM Pass
date: 2022-11-14
author: 黃明瀧 111062612
CJKmainfont: Source Han Sans
toc: true
---

# Building and Running the Pass

The code of the pass relies on some C++17 language features, so in order to build, the `--std=c++17`
flag is required.  The `Makefile` attached with my homework submission already contains it.
Clang 9.0 is verified to be able to build the pass.

## Automated Way

Run `./run.sh` attached with my homework submission.
New testcases can be added by editing the `Makefile`.

## Manual Way

To build and run the pass manually, perform the following steps.

1. Make sure that `Makefile`, `hw1.cpp`, and `diophantine.hpp`, are in the working directory.
2. Run `make hw1.so` to build.
3. Run `clang -S -emit-llvm -O0 -g <source.c> -o <output.ll>` to build IR module.
4. Run `opt -load ./hw1.so -data-dep -o /dev/null <output.ll>` to run the pass.


# Test Cases My Pass Handles

Both test case 1 and 2 from the spec of the homework can be analyzed.
Additionally, multiple non-nested loops within the same file can also be analyzed.

The following assumptions are made in my LLVM data dependency pass.

1. The input `.ll` IR files are compiled from C source with `-O0 -g` flags.  This is done in the `Makefile` attached.
2. The step size of the loop induction variable (i.e. `i`) is `1`.
3. Each statement inside the body of the loop is in the following form, where `c`, `d`, `e`, and `f` are optional integer literals.

   ```cpp
   A[c * i + d] = B[e * i + f];
   ```

   Here, `A` and `B` are names of local array variables, and `i` is the name of the loop induction variable.

## Test Case 1

Input C source code.

```cpp
int main(){
    int i;
    int A[20], B[20], C[20];
    for (i = 4; i < 20; i++) {
        A[i] = C[i];
        B[i] = A[i - 4];
    }
    return 0;
}
```

Output from the pass.

```c
LOOP: Loop at depth 1 containing: %for.cond<header><exiting>,%for.body,%for.inc<latch>

===Flow Dependencies===
Array A: S1 (i =  4) --> S2 (i =  8)
Array A: S1 (i =  5) --> S2 (i =  9)
Array A: S1 (i =  6) --> S2 (i = 10)
Array A: S1 (i =  7) --> S2 (i = 11)
Array A: S1 (i =  8) --> S2 (i = 12)
Array A: S1 (i =  9) --> S2 (i = 13)
Array A: S1 (i = 10) --> S2 (i = 14)
Array A: S1 (i = 11) --> S2 (i = 15)
Array A: S1 (i = 12) --> S2 (i = 16)
Array A: S1 (i = 13) --> S2 (i = 17)
Array A: S1 (i = 14) --> S2 (i = 18)
Array A: S1 (i = 15) --> S2 (i = 19)
===Anti-Dependencies===
===Output Dependencies===
```

## Test Case 2

Input C source code.

```cpp
int main(){
    int i;
    int A[40], C[40], D[40];
    for (i = 2; i < 20; i++) {
        A[i] = C[i];
        D[i] = A[3 * i - 4];
        D[i - 1] = C[2 * i];
    }
    return 0;
}
```

Output from the pass. The anti-dependencies are ordered decreasingly due to some implementation details.

```c
LOOP: Loop at depth 1 containing: %for.cond<header><exiting>,%for.body,%for.inc<latch>

===Flow Dependencies===
Array A: S1 (i =  2) --> S2 (i =  2)
===Anti-Dependencies===
Array A: S2 (i =  7) --> S1 (i = 17)
Array A: S2 (i =  6) --> S1 (i = 14)
Array A: S2 (i =  5) --> S1 (i = 11)
Array A: S2 (i =  4) --> S1 (i =  8)
Array A: S2 (i =  3) --> S1 (i =  5)
===Output Dependencies===
Array D: S2 (i =  2) --> S3 (i =  3)
Array D: S2 (i =  3) --> S3 (i =  4)
Array D: S2 (i =  4) --> S3 (i =  5)
Array D: S2 (i =  5) --> S3 (i =  6)
Array D: S2 (i =  6) --> S3 (i =  7)
Array D: S2 (i =  7) --> S3 (i =  8)
Array D: S2 (i =  8) --> S3 (i =  9)
Array D: S2 (i =  9) --> S3 (i = 10)
Array D: S2 (i = 10) --> S3 (i = 11)
Array D: S2 (i = 11) --> S3 (i = 12)
Array D: S2 (i = 12) --> S3 (i = 13)
Array D: S2 (i = 13) --> S3 (i = 14)
Array D: S2 (i = 14) --> S3 (i = 15)
Array D: S2 (i = 15) --> S3 (i = 16)
Array D: S2 (i = 16) --> S3 (i = 17)
Array D: S2 (i = 17) --> S3 (i = 18)
Array D: S2 (i = 18) --> S3 (i = 19)
```


# Implementation Report

## The `DataDepPass` Class

This is a subclass of `FunctionPass`.
Upon every function it encounters, it gets `LoopInfo` from another analytics pass (to identify loops within the input module), and then creates an `FunctionDataDep` object, which takes care of the rest.

## The `FunctionDataDep` Class

For every loop it encounters, it performs the following steps to eventually print out the data dependencies.
These steps can be seen in `FunctionDataDep::processLoop()`.

1. Find the loop induction variable, along with its related informations.
   1. Find the `icmp` instruction within the header block of the loop.
   2. Find the `alloca` instruction from the `icmp` instruction. This is the loop induction variable.
   3. Find the `store` instruction that writes to the loop induction variable inside the predecessor block of the loop. This is where the initial value of the loop induction variable is set.
   4. Extract the constant integers from operands of the `store` instruction and the `icmp` instruction. These are the starting (inclusive) and ending (exclusive) values of the loop induction variable.
2. Find the body block of the loop.
3. Split the list of instructions in the body block into segments, with each segment representing a statement in the original C source code.
   This is done by splitting the list after each `store` instruction, as each statement is assumed to have only one `store`.
   The last instruction (which is always a `br` instruction) is discarded.
4. Find and print the flow dependencies and anti-dependencies.
5. Find and print the output dependencies.

The detailed procedure for steps 4 and 5 are described in the next sections.

## Finding Flow and Anti Dependencies

Given $n$ statements, labeled as $S_1$ to $S_n$, the procedure goes through all $(S_k, S_l)$ pairs of statements within $\{ S_1, \dots, S_n\}^2$.
For each $(S_k, S_l)$ pair of statements, the LHS of $S_k$ (say `X[c1 * i + d1]`) and the RHS of $S_l$ (say `Y[c2 * i + d2]`) are examined.

1. Abort if `X != Y`.
2. Abort if $GCD(c_1, c_2) \nmid d_2 - d_1$.
3. Solve the equation $c_1 x - c_2 y = d_2 - d_1$ using a diophantine equation solver, yielding parametric equations in $t$ for the values $x$, $y$ of the loop induction variable.
4. Using the range of the loop induction variable and the solution of the diophantine equation, find out the range of $t \in (t_l, t_u)$ where both $x$ and $y$ are within the range.
5. For $t \in (t_l, t_u)$, calculate the values of $x$ and $y$.
   1. If $(x, k) > (y, l)$, then report an anti-dependency from statement $S_l$ to $S_k$, with loop induction variable values $y$ and $x$.
   2. Otherwise, report a flow dependency from statement $S_k$ to $S_l$, with loop induction variable values $x$ and $y$.

As the diophantine equation solver attached with the homework spec predates modern C and modern C++, the solver is modified for compilation with C++17.
The algorithm and function implementations are unchanged.

The procedure is implemented in `FunctionDataDep::findRWDependencies()`.

## Finding Output Dependencies

The procedure to find output dependencies is almost identical to the one described in the previous section,
except for that for each $(S_k, S_l)$ pair of statements, the LHS's of the twh statements are examined.

The procedure is implemented in `FunctionDataDep::findOutputDependencies()`.

# Grading

|Done?|Rank   |Request                                     |
|-----|-------|--------------------------------------------|
|Yes|D      |Document only                               |
|Yes|C- ~ C+|Makefile for .so and .ll, bash file for test|
|Yes|B-     |Pass test1.c                                |
|Yes|B      |Pass test2.c                                |
|Maybe|B+     |Pass test3.c(hidden)                        |
|Yes|A-     |Write document with Latex                   |
|Yes|A      |Solve diophantine |
|Maybe not|A+     |Pass test4.c(hidden)                        |

# Building This Document

The \LaTeX source of this document is attached with the homework submission.
This document can be built with the following prerequisites.

- `xelatex` from a TeX Live installation
- Noto CJK fonts

On Overleaf, it may be required to set the compiler to `xelatex` from the menu.

<!-- vim: set ft=markdown: -->
