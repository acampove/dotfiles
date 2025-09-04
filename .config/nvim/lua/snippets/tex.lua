local ls    = require("luasnip")
local snip  = ls.snippet
local text  = ls.text_node

local utils = require("snippets.utils")
local snipf = utils.snippetf

-----------------------------------------------------
--- Slides
-----------------------------------------------------
intro = snipf("intro", [[
\begin{frame}[plain]
  \centering
  \vspace*{0.3\textheight}
  {\Huge \bfseries {1}}
  
  \vspace{1cm}
  {\Large {2}}
\end{frame}
]])
-----------------------------------------------------
--- Tables
-----------------------------------------------------
s_2subfigs = snipf("subfig2", [[
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{1}}
        \caption{{2}}
    \end{subfigure}
    \hfill
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{3}}
        \caption{{4}}
    \end{subfigure}
    \caption{{5}}
\end{figure}
]])

s_3subfigs = snipf("subfig3", [[
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{1}}
        \caption{{2}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{3}}
        \caption{{4}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{5}}
        \caption{{6}}
    \end{subfigure}
    \caption{{7}}
\end{figure}
]])

s_4subfigs = snipf("subfig4", [[
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{1}}
        \caption{{2}}
    \end{subfigure}
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{3}}
        \caption{{4}}
    \end{subfigure}
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{5}}
        \caption{{6}}
    \end{subfigure}
    \begin{subfigure}[b]{0.45\textwidth}
        \includegraphics[width=\textwidth]{{7}}
        \caption{{8}}
    \end{subfigure}
    \caption{{9}}
\end{figure}
]])

s_6subfigs = snipf("subfig6", [[
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{1}}
        \caption{{2}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{3}}
        \caption{{4}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{5}}
        \caption{{6}}
    \end{subfigure}

    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{7}}
        \caption{{8}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{9}}
        \caption{{10}}
    \end{subfigure}
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{{11}}
        \caption{{12}}
    \end{subfigure}
    \caption{{13}}
\end{figure}
]])

s_8subfigs = snipf("subfig8", [[
\begin{figure}[htbp]
    \centering
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{1}}
        \caption{{2}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{3}}
        \caption{{4}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{5}}
        \caption{{6}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{7}}
        \caption{{8}}
    \end{subfigure}

    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{9}}
        \caption{{10}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{11}}
        \caption{{12}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{13}}
        \caption{{14}}
    \end{subfigure}
    \begin{subfigure}[b]{0.23\textwidth}
        \includegraphics[width=\textwidth]{{15}}
        \caption{{16}}
    \end{subfigure}
    \caption{{17}}
\end{figure}
]])

s_left_margin = snipf("left_margin", [[
    \begin{textblock}{10}(-1, +7) 
        \textred{{2}}
    \end{textblock}
    \begin{textblock}{10}(-1, +2) 
        \textred{{1}}
    \end{textblock}
]])
-----------------------------------------------------
return {
    intro,
    s_2subfigs,
    s_3subfigs,
    s_4subfigs,
    s_6subfigs,
    s_8subfigs,
    s_left_margin,
}
