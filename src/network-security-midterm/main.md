---
title: Network Security Midterm
date: 2022-11-09
author:
  - 黃明瀧 111062612
institute:
CJKmainfont: Source Han Sans
---


# 1(a)

> Patient allergy information is an example of an asset with a moderate requirement for integrity.

False.  Patient allergy information is an example of an asset with high requirement for integrity,
otherwise attackers may be able to make the data inaccurate, resulting in harm or death to the
patients of the hospital.

# 1(b)

> Data origin authentication provides protection against the duplication or modification of data
> units.

False.  Data origin authentication only provides proof of the source of the data unit i.e. the sender
to be the specified party, and does not provide any protection against the duplication nor
modification.

# 1(c)

> A connection-oriented integrity service deals with individual messages without regard to any
> larger context and generally provides protection against message modification only.

False.  Unlike a connectionless integrity service, a connection-oriented integrity service, as suggested by its name, deals with a stream of
messages, checking whether there are any duplication, insertion, modification, reordering, or
replays, or not.

# 1(d)

> The advantage of a block cipher is that you can reuse keys.

True.  Mentioned in paragraph 1, page 47 of the textbook, the advantage of a block cipher is that you can reuse keys.

# 1(e)

> The security of symmetric encryption depends on the secrecy of the algorithm, not the secrecy of the key.

False.  Only the encryption keys are kept secret, as the symmetric encryption algorithms are designed such that it is impractical to decrypt without having *both* the keys and the algorithms.

# 1(f)

> The two important aspects of encryption are to verify that the contents of the message have not been altered and that the source is authentic.

False.  These two are the important aspects of authentication (from paragraph 1, page 15 of the textbook) and, not encryption.

# 2

> State Kirchhoff’s principle. Explain briefly why a cryptosystem designed by someone
who follows this principle is likely to be stronger than one designed by someone who
does not.

"A cryptosystem should be secure even if everything about the system, except the key, are publicly known."

For those cryptosystems that are *not* designed following this principle, however hard its users try to hide the algorithms from thirt party attackers, there's no guarantee that the algorithms will remain secret forever.  Besides, a non-publicly-known cryptosystem doesn't get a chance for security experts to validate the security of the system, which is an important reason why publicly-known systems are deemed secure.

# 3

> DES is insecure because of its short key length (56 bits). A modified DES algorithm
> has key length of 120 bits, $k = (k_1 , k_2)$, where $k_1$ is 56 bits and $k_2$ is 64 bits. The new
> encryption algorithm is as follows.
> 
> $$DES'(k, m) = k_2 ⊕ DES(k_1 , (k_2 ⊕ m))$$
> 
> Explain how decryption is done.

Denote the original decryption function as $dDES$ and the new decryption function as $dDES'$ where the lowercase d stands for decryption.  $dDes'(k, c)$ is defined as the following.

$dDES'(k, c) = k_2 ⊕ dDES(k_1, k_2 ⊕ c)$


# 4

> Briefly explain the Shift Rows and Byte Substitution layers in AES algorithm. What
> happens if we change their order in the AES algorithm (Shift Rows and then Byte
> Substitution)?

Nothing happens, and the output ciphertext does not change after changing their order.  Because the *Shift Rows* operation only moves the bytes and the *Byte Substitution* operation only replaces bytes according to a lookup table, their order does not matter.  In other words, they are commutative.


# 5(a)

> In Cipher Block Chaining (CFB) mode of operation, describe the encryption and decryption process.

The encryption process consists of the following steps, assuming that the unit of transmission is $s$ bits.

1. Initialize the $n$-bit-wide shift register to some initialization vector.
2. Encrypt the data from the shift register with a symmetric key $K$, resulting in a $n$-bit-wide output.
3. XOR the leftmost $s$ bits of the $n$-bit-wide output with the next $s$ bits (denoted by $p_i$) of the input, resulting in ciphertext $c_i$.
4. Shift the shift register left by $s$ bits, and fill the lowest bits with the ciphertext $c_i$ obtained in step 3.
5. Repeat steps 2-4 until all input plaintext are processed.

The decryption process consists of the following steps.  The process is almost identical to the encryption process, except for that the ciphertext to be put into the shift register in step 4 is available directly.

1. Initialize the $n$-bit-wide shift register to the initialization vector.
2. Encrypt the data from the shift register with a symmetric key $K$, resulting in a $n$-bit-wide output.
3. XOR the leftmost $s$ bits of the $n$-bit-wide output with the next unit of ciphertext $c_i$, resulting in plaintext $p_i$.
4. Shift the shift register left by $s$ bits, and fill the lowest bits with the ciphertext $c_i$.
5. Repeat steps 2-4 until all input ciphertext are processed.

# 5(b)

> Show that a transmission bit error in $c_i$ affects correctness of $m_i$ and the next
> $\lceil n/s \rceil$ plaintext blocks.

A bit error in $c_i$ affects the value in the shift register starting from the next round (when decrypting $c_2$),
and since the shift register is $n$-bit-wide, it takes $\lceil n/s \rceil$ left shifts of $s$ bits for one to make sure that the bit error is "shifted out" of the shift register.

# 6(a)

> We consider a banking system, where message $m$ of the form *fromAccount*, *toAccount*,
> and *amount* are sent within the bank network, with the meaning that amount dollars
> should be transferred from *fromAccount*, to *toAccount*. Each message consists of three
> blocks, with each block holding one of the three parameters. Messages are encrypted
> with AES in Counter Mode as follows:
> 
> $$K_j = E(k, T_j ), C_j = M_j ⊕ K_j$$
> 
> Each of the three parts of a message is sixteen characters, i.e., one block, so messages
> consist of three blocks.

> The adversary has an account in the bank and can intercept and changes messages.
> Imagine now that he know the *toAccount* for a particular message $m = C_1 C_2 C_3$.
> Explain how he can modify the message so that the amount is transferred to his own account.

Since the adversary knows the *toAccount* (i.e. $M_2$) corresponding to the intercepted ciphertext $C_2$,
they can derive the intermediate key $K_2$ by computing $K_2 = C_2 ⊕ M_2$.
The adversary can then proceed to encrypt their own account, say $M_2'$, by computing $C_2' = M_2' ⊕ K_2$,
and replace $C_2$ in the transmitted message with $C_2'$, thus making the amount transferred to their own account.

# 6(b)

> (cont'd) Explain how the use of MAC would prevent this attack.

MAC (message authentication code) is a small block of data appended to the message itself,
computed by feeding the message *and also the shared key* into some encryption algorithm.
Upon receiving the message from the sender, the receiver performs the same encryption computation
to check whether the result compued locally matches the received MAC.

With the use of MAC, even if the adversary in 6(a) knows the *toAccount* of a message (and therefore gaining knowledge of the intermediate key $K_2$), since the adversary does not know the actual shared key $k$, it's impossible to find a new matching MAC.  Thus, the receiver will be able to notice that the message is changed, and the transfer will not be conducted.

# 7

> When one signs an electronic document using digital signature, one often performs the
> signature operation on a message digest produced by passing the document through
> a cryptographically strong hash function $h = H(m)$. Why it is important that it is
> difficult to find two documents with the same message digest?

Such property of hash functions is called (strong) collision resistant.  Without this property, attackers can may be able to find another document $m' \neq m$ with the same has value $H(m') = H(m)$, and the user will not be able to notice that the document has been replaced.

# 8

> In RSA algorithm, is it possible for more than one $d$ to work with a given $e$, $p$, and $q$?
> Hint (Is it possible to have $d$ and $u$ s.t. $ed = 1 mod φ(n)$ and $eu = 1 mod φ(n)$?)

No, it is not possible for more than one $d$ to work with a given tuple $(e, p, q)$.  The proof follows.

Given a tuple $(e, p, q)$, let $n = pq$.
Suppose that there are two distinct values $d$ and $b$ that works with the tuple.
Then, under the group $\mathbb{Z}_{\phi(n)}$, we have

$$\begin{cases}de = 1 \\ be = 1\end{cases}$$

$\because de = 1 \, \therefore dbe = b$

$\because dbe = b$ and $be = 1 \, \therefore d1 = b$

$\implies d = b$, which contradicts to our previous assumption that $d$ and $b$ are two distinct values.
Therefore, it is not possible for more than one $d$ to work with the a given $e$, $p$, and $q$.
