---
title: Homework 1 - Network Security
date: 2022-11-21
author: 黃明瀧 111062612
CJKmainfont: Source Han Sans
---

# 2 (a)

> Consider a desktop publishing system used to produce documents for various organizations.
>
> Give an example of a type of publication for which confidentiality of the stored data is the most important requirement.

For publications involving internal trade secrets within companies, confidentiality of the data is the most important requirement.

# 2(b)

> (cont'd) Give an example of a type of publication in which data integrity is the most important requirement.

For documents used in medical care institutions like hospitals that involves critical data of the patients (for example formal reports of medical examinations), data integrity is the most important requirement.

# 2(c)

> (cont'd) Give an example in which system availability is the most important requirement.

For documents that must be produced on a timely manner (e.g. daily newsletter), system availability is the most important requirement.

# 3

> Alice was told to design a scheme to prevent messages from being modified by an attacker. Alice decides to append to each message a hash (message digest) of that message. Why doesn’t this solve the problem?

Suppose that the attacker can modify the message during transmittion. In that case, the attacker can modify the message body itself **and also the hash value**, without being noticed by the receiver.

# 4

> What RC4 key value will leave $S$ unchanged during initialization? That is, after the initial permutation of $S$, the entries of $S$ will be equal to the values from 0 through 255 in ascending order.

Taken from the textbook, the following pseudocode describes the initialization procedure of RC4.

```c
j = 0;
for i = 0 to 255 do
  j = (j + S[i] + T[i]) mod 256;
  Swap(S[i], S[j]);
```

Using the pseudocode, we can deduce a key $K$ of length 256 in bytes (so $T = K$) that makes $S$ unchanged during the procedure.
We do this by always making the two arguments passed to `Swap()` the same element of $S$.

- For iteration `i == 0`, we want `j` to be 0, so `0 == (0 + 0 + T[0]) mod 256`, so `T[0] == 0`.
- For iteration `i == 1`, we want `j` to be 1, so `1 == (0 + 1 + T[1]) mod 256`, so `T[1] == 0`.
- For iteration `i == 2`, we want `j` to be 2, so `2 == (1 + 2 + T[2]) mod 256`, so `T[2] == 255`.
- For iteration `i == 3`, we want `j` to be 3, so `3 == (2 + 3 + T[3]) mod 256`, so `T[3] == 254`.

Similarly, we have `T[4] == 253`, `T[5] == 252`, ..., and finally `T[255] == 2`.
Since $T = K$, we have $K = 0, 0, 255, 254, 253, 252, \dots, 2$.

# 5


