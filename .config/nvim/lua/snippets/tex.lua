local ls    = require("luasnip")
local snip  = ls.snippet
local text  = ls.text_node

local utils = require("snippets.utils")
local snipf = utils.snippetf

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
-----------------------------------------------------
return {
    s_2subfigs,
    s_3subfigs,
    s_4subfigs,
}
