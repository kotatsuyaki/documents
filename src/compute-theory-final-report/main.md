---
title: '計算理論期末報告'
subtitle: 'Theory of Computation, NTHU'
author: '107021129 黃明瀧'
date: 2022-06-17
bibliography: citations.bibtex

abstract: |
  此份報告的內容基於教科書[@i2toc]編寫，
  符號與定義多與教科書相同。
  部分證明細節取自上課教材[@wkhontoc]。

figPrefix: 圖
reference-section-title: 引用

CJKmainfont: Source Han Sans
fontsize: 11pt

header-includes:
  - |
    \DeclareMathOperator{\TM}{\mathsf{TM}}
    \DeclareMathOperator{\ITM}{\mathit{INFINITE}_{\mathsf{TM}}}
    \DeclareMathOperator{\ATM}{\mathit{A}_{\mathsf{TM}}}
    \DeclareMathOperator{\PCP}{\mathsf{PCP}}
    \DeclareMathOperator{\Lang}{L}
  - |
    \newcommand{\Desc}[1]{\left\langle #1 \right\rangle}
    \newcommand{\Domino}[2]{\Bigg[\displaystyle\frac{\mathtt{#1}}{\mathtt{#2}}\Bigg]}
    \newcommand{\DominoS}[2]{\Bigg[\displaystyle\frac{#1}{#2}\Bigg]}
    \newcommand{\DominoL}[2]{\left[\frac{\mathtt{#1}}{\mathtt{#2}}\right]}
  - |
    \usepackage{amsthm}
    \newtheorem{thm}{Theorem}
    \newtheorem{lem}{Lemma}
---


# TM = NTM

::: {.thm}
給定任意的非確定型圖靈機[^1]$N$，
存在確定型圖靈機[^2]$D$使得$L(N) = L(D)$。
:::

::: {.proof}
令$N$為一非確定型圖靈機。
已知多帶圖靈機[^3]與確定型圖靈機具有相同的計算能力，
故若我們可以建構出多帶圖靈機$D$使得$L(N) = L(D)$，
則定理得證。
以下我們以一多帶圖靈機$D$來模擬$N$的運算。

令$D$為一包含三條紙帶的多帶圖靈機，其中

- 紙帶1記錄原始輸入字串$\omega$。
- 紙帶2記錄模擬的過程；類似於記憶體。

  舉例來說，`0#01`代表目前紙帶上的字串為`001`，
  且讀寫頭位於第二個字符的位置。
- 紙帶3記錄在計算樹[^4]應選擇的分支。

  舉例來說，`231`代表應依序選擇根節點的第二個子節點
  、該子節點的第三個子節點
  、該子節點的第一個子節點來做運算。

紙帶3的字符集合$\Gamma_b$大小由$N$的計算樹的分歧度[^5]$b$所決定。
$b$可以由$N$的狀態集及字符集推得。

$$b = \Big |Q \times \Gamma \times \{ L, R \} \Big|$$

以下給出$D$的演算法文字敘述。對於輸入字串$\omega$，

1. 將$\omega$寫至紙帶1。初始化紙帶2及3為空。
2. 複製紙帶1的內容至紙帶2，作為模擬用的輸入字串。
3. 依照紙帶3記錄的內容，在紙帶2上模擬$N$的運算。
   在模擬每一步驟之前，確認以下條件。

   a. 根據$N$之轉移函數$\delta$，若此步驟為非法，則跳至步驟4。
   b. 若紙帶3上已無任何字符，則跳至步驟4。
   c. 根據$N$之拒絕狀態$q_\text{reject}$，若目前模擬的狀為為拒絕狀態，則拒絕。
   d. 根據$N$之接受狀態$q_\text{accept}$，若目前模擬的狀態為接受狀態，則接受。
4. 依照字典序，將紙帶3上的字串改為下一個字串。跳至步驟2。

上述多帶圖靈機$D$會依序模擬$N$執行0步$\to$執行1步$\to$執行2步……，
以廣度優先的方式嘗試所有運算路徑，
故$D$接受（拒絕）字串$\omega$若且唯若$N$接受（拒絕）字串$\omega$。
因此，$L(N) = L(D)$。
:::


[^1]: 非確定型圖靈機 = Nondeterminstic Turing machine
[^2]: 確定型圖靈機 = Deterministic Turing machine
[^3]: 多帶圖靈機 = Multitape Turing machine
[^4]: 計算樹 = Computation tree
[^5]: 分歧度 = Degree


# Rice's Theorem

::: {.thm info="Rice's Theorem"}
令 $P$ 為一語言，使得下列兩條件成立，則 $P$ 是不可判定[^6]的。

1. $P$ 是非平凡[^7]的；
   亦即存在圖靈機 $M$使得$\Desc{M} \in P$，
   但不是所有的圖靈機的敘述都屬於 $P$。
2. $P$ 是語言的性質；
   亦即若 $\Lang(M_1) = \Lang(M_2)$，
   則 $\Desc{M_1} \in P \Leftrightarrow \Desc{M_2} \in P$。
   換句話說，一個圖靈機的敘述是否屬於 $P$，
   只與該圖靈機對應的語言有關。
:::

::: {.proof}
我們以反證法證明 Rice's Theorem。
假設 $P$ 是可判定的。
令 $M_P$ 為判定 $P$ 的圖靈機。
我們將使用 $M_P$ 來建構出可判定 $\ATM$ 的圖靈機。

令 $T_\emptyset$ 為一拒絕所有輸入的圖靈機。$\Lang(T_\emptyset) = \emptyset$。
不失一般性[^8]，假設 $\Desc{T_\emptyset} \not \in P$。
由條件1，令 $T$ 為圖靈機，使得 $\Desc{T} \in P$。

利用 $P$ 可以「分辨」出 $T_\emptyset$ 與 $T$ 之間差異的能力，
對於輸入 $\Desc{M, \omega}$，設計以下圖靈機 $S$ ，作為 $\ATM$ 的判定器。

1. 利用 $M$ 與 $\omega$ 來建構圖靈機 $M_\omega$：

   對於輸入 $x$，

   a. 以 $\omega$ 作為輸入模擬 $M$ 的執行。
      若 $M$ 拒絕，則拒絕。
   b. 以 $x$ 作為輸入模擬 $T$ 的執行。
      若 $T$ 接受，則接受。
2. 以 $M_P$ 來判斷 $\Desc{M_\omega}$ 是否屬於 $P$。
   若 $\Desc{M_\omega} \in P$，則接受。
   若 $\Desc{M_\omega} \not \in P$，則拒絕。

為什麼 $S$ 可以判定 $\ATM$ 呢？
我們可以討論兩種情形，分析 $S$ 的行為。

- 若 $M$ 接受 $\omega$ ，則 $M_\omega$ 會進入步驟 1b 
  $\implies \Lang(M_\omega) = \Lang(T)$
  $\implies \Desc{M_\omega} \in P$
- 若 $M$ 拒絕 $\omega$ ，則 $M_\omega$ 會拒絕所有輸入字串 $x$
  $\implies \Lang(M_\omega) = \Lang(T_\emptyset)$
  $\implies \Desc{M_\omega} \not \in P$

我們可以看出 $\Desc{M_\omega} \in P$ 若且唯若 $M$ 接受 $\omega$，
因此 $S$ 可以判定 $\ATM$。
然而我們已知 $\ATM$ 是一個不可判定的語言，
所以此結論為矛盾。
因此， $P$ 不可判定。
:::

以下舉例說明如何使用 Rice's Theorem
證明 $\ITM = \Big\{ \Desc{M} \Big | |\Lang(M)| = \infty \Big\}$ 的不可判定性。

::: {.proof}
要使用 Rice's Theorem，我們需要驗證 $\ITM$ 是否符合定理的兩個前提。

1. 令 $T_{\text{all}}$ 為接受所有輸入字串的圖靈機。
   因 $\Desc{ T_{\text{all}} } \in \ITM$ 且 $\Desc{ T_\emptyset } \not \in \ITM$，
   故 $\ITM$ 是非平凡的。
2. $\ITM$ 的定義只與 $\Lang(M)$ 有關，
   故 $\ITM$ 是語言的性質。

$\ITM$ 符合 Rice's Theorem 的兩個前提，因此 $\ITM$ 是不可判定的。
:::

[^6]: 不可判定 = Undecidable
[^7]: 非平凡 = Nontrivial
[^8]: 若 $\Desc{T_\emptyset} \in P$，
      則整個證明可以改以 $\overline{P}$ 來進行，
      使得 $\Desc{T_\emptyset} \not \in P$。


# Post Correspondence Problem

## PCP 問題簡述

PCP 問題建立在一個以骨牌進行的益智遊戲上。
每張骨牌形如

$$\DominoS{t}{b} = \Domino{a}{ab}$$

分為上下兩個部分，分別載有一個字串。
令 $P$ 為一個骨牌的集合，例如

$$P = \left\{ \Domino{b}{ca}, \Domino{a}{ab}, \Domino{ca}{a}, \Domino{abc}{c} \right\}$$

。對於某些 $P$ ，我們可以找到一個（可重複的）骨牌排列方式，
使得「骨牌上半的所有字符所組成的字串」與「骨牌下半的所有字符鎖組成的字串」相等。
以前述 $P$ 為例，

$$\Domino{a}{ab} \Domino{b}{ca} \Domino{ca}{a} \Domino{a}{ab} \Domino{abc}{c}$$

即為一個合法的**對應**[^9]。
判斷一個骨牌的集合 $P$ 是否存在這樣的排列方式，即為波斯特對應問題。
以形式語言的方式來說：

$$\PCP = \left\{ \Desc{P} \mid| P \text{為一個存在對應的 Post Correspondence Problem 的實例} \right\}$$

可以證明 $\PCP$ 是一個不可判定的語言。


## 使用 PCP 做計算

給定一個圖靈機 $M$ ，
我們可以設計出一組特別的骨牌 $P$ ，
使得在解 PCP 的過程中，
骨牌排出的字串模擬了圖靈機的運算過程。

以下以舉例的方式說明用 (M)PCP 模擬計算的方法。
令 $M$ 為一台「只接受 `01` 並改寫為 `10`」的圖靈機。
我們可以給出它的轉移函數 $\delta$，以供設計骨牌時參考。

$$\begin{cases}
q(q_0, 0) &= (q_1, 1, R) \\
q(q_1, 1) &= (q_\text{accept}, 0, R) \\
q(q, x) &= (q_\text{reject}, \_, R) \text{ otherwise }
\end{cases}$$

依據教科書[@i2toc]第229頁所述之骨牌設計方式，
$P$ 包含下列骨牌。

- Part 1: $\Domino{\#}{\#q_001\#}$

- Part 2: $\Domino{q_00}{1q_1}$, $\Domino{q_11}{0q_\text{accept}}$

- Part 3: 此圖靈機無向左移動的可能，故不適用。

- Part 4: $\Domino{0}{0}$, $\Domino{1}{1}$

- Part 5: $\Domino{\#}{\#}$, $\Domino{\#}{\_\#}$

- Part 6:
  $\Domino{0q_\text{accept}}{q_\text{accept}}$, $\Domino{q_\text{accept}0}{q_\text{accept}}$,
  $\Domino{1q_\text{accept}}{q_\text{accept}}$, $\Domino{q_\text{accept}1}{q_\text{accept}}$

- Part 7: $\Domino{q_\text{accept}\#\#}{\#}$

以 $\Domino{\#}{\#q_001\#}$ 作為開頭，
則一開始我們會得到上下不相等的骨牌：

$$\Domino{\#}{\#\textcolor{red}{q_001\#}}$$

注意紅色的部分以 $q_00$ 開頭。
若我們想要上下相等的字串，
則需要上半部以 $q_00$ 開頭的骨牌作為下一張骨牌。
在 $P$ 中，這樣的骨牌只有一張，故我們得到：

$$\Domino{\#}{\#q_00\textcolor{red}{1\#}} \Domino{q_00}{\textcolor{red}{1q_1}}$$

按照相同的邏輯，
在每個步驟我們都尋找 $P$ 中符合目前「多出來」的字串的骨牌，
依序排上，
則最後可以得到：

$$
\Domino{\#}{\#\textcolor{blue}{q_001}\#}
\Domino{q_00}{\textcolor{blue}{1q_1}}
\Domino{1}{\textcolor{blue}{1}}
\Domino{\#}{\#}
\Domino{1}{\textcolor{blue}{1}}
\Domino{q_11}{\textcolor{blue}{0q_\text{accept}}}
\Domino{\#}{\#}
\Domino{1}{\textcolor{blue}{1}}
\Domino{0q_\text{accept}}{\textcolor{blue}{q_\text{accept}}}
\Domino{\#}{\#}
\Domino{1q_\text{accept}}{\textcolor{blue}{q_\text{accept}}}
\Domino{\#}{\#}
\Domino{q_\text{accept}\#\#}{\#}
$$

注意藍色部分以井字號 $\#$ 分隔，
對應到的即是 $q_001 \vdash 1q_11 \vdash 01q_\text{accept}$ 的計算；
後方冗餘的項只是因應上下對應所需。

在這個例子中為了舉例方便，
我們使用了 MPCP 版本，
亦即第一張骨牌被指定為 $\DominoL{\#}{\#q_001\#}$。
若要使用 PCP 來進行計算，
則需要事先在每張骨牌上插入一些 $\star$ 字符，
用以強迫任何對應必須要以該骨牌開頭。

[^9]: 對應 = Match
