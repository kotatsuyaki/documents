---
title: Homework 1 - Network Security
date: 2022-11-21
author: 黃明瀧 111062612
CJKmainfont: Source Han Sans
---

# 1

> Consider a system that provides authentication services for critical systems, applications, and devices. Give examples of confidentiality, integrity, and availability requirements associated with the system. In each case, indicate the degree of importance of the requirement.

- Confidentiality: Within storage and during transmission, the system **must** keep the hashed passwords and personal metadata confidential.
- Integrity: Within storage and during transmission, the system **must** be able to self-monitor to ensure integrity ot the hashed passwords and personal metadata.
- Availability: The system has to be kept online, otherwise other systems relying on the authentication services may not be able to operate normally. This requirement is less important in the sense that unlike the previous two requirements, system outages can often be resolved without permanent damage.

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

Suppose that the attacker can modify the message during transmission. In that case, the attacker can modify the message body itself **and also the hash value**, without being noticed by the receiver.

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

> With the ECB mode, if there is an error in a block of the transmitted ciphertext, only the corresponding plaintext block is affected. However, in the CBC mode, this error propagates. For example, an error in the transmitted $C_1$ obviously corrupts $P_1$ and $P_2$. Are any blocks beyond $P_2$ affected?

No, blocks beyond $P_2$ are not affected by the error in $C_1$.

With the CBC mode of operation, each decrypted plaintext $P_i$ (where $i \neq 1$) depends exactly on $C_{i - 1}$, $C_i$, and the key $K$, so plaintexts staring from $P_3$ does not depend on $C_1$ anymore.

# 6

> Is it possible to perform encryption operations in parallel on multiple blocks of plaintext in CBC mode? How about decryption?

- CBC mode encryption **cannot** be paralellized at all, since $C_i$ depends on $C_{i - 1}$, which then depends on $C_{i - 2}$ and so on, making serialized computation the only possible implementation.
- CBC mode decryption **can** be parallized. For decryption, $P_i$ depends exactly on $K$, $C_i$, and $C_{i - 1}$ and nothing more, making it plausible to compute multiple $P_i$ blocks simultaneously, as long as the ciphertext blocks are received.

# 7

> Suppose $H(m)$ is a collision-resistant hash function that maps a message of arbitrary bit length into an $n$-bit hash value. Is it true that, for all messages $x$, $x'$ with $x \neq x'$, we have $H(x) \neq H(x')$? Explain your answer.

No, the statement is not true. The domain of $H$ has a cardinality of $\infty$ due to the arbitrary bit length of input messages, while the cardinality of the image of $H$ is constrained to be $\leq 2^n$ unique values due to the bit length of the hash values. This makes it impossible for $H$ to be injective.

# 8

> It is possible to use a hash function to construct a block cipher with a structure similar to DES. Because a hash function is one way and a block cipher must be reversible (to decrypt), how is it possible?

As seen in the round function of DES (and the Fiestel Structure), the hash function is only to be used to map some values to XOR masks. The inputs to the hash function are still available (or deducible) after encryption, so the whole process is still reversible.

# 9

> In an RSA system, the public key of a given user is $e = 3$, $n = 667$. What is the private key for this user?

By prime-factorizing $n$, we get $n = 667 = 29 \times 23$, so we have $(p, q) = (29, 23)$ and $\phi(n) = 28 \times 22 = 616$.
By solving $3d \mod 616 = 1$, we get $d = 411$.

Therefore, the private key is $\{d, n\} = \{411, 667\}$.
