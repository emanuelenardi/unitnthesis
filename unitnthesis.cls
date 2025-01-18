%% File: unitnthesis.cls
%% ----------------------------------------------------------------------
%% LaTeX3 class for Academic Theses at the University of Trento (UniTN)
%% ----------------------------------------------------------------------
%% 
%% EXPERIMENTAL CODE
%% 
%% Do not distribute a modified version of this file.
%% 
%% File: unitnthesis Copyright (C) 2024-present Emanuele Nardi
%%
%% It may be distributed and/or modified under the conditions of the
%% LaTeX Project Public License (LPPL), either version 1.3c of this
%% license or (at your option) any later version.  The latest version
%% of this license is in the file
%%
%%    http://www.latex-project.org/lppl.txt
%%
%% This work consists of the files unitnthesis.cls and README.md.
%%
%% This work has the LPPL maintenance status `maintained'.
%%
%% The Current Maintainer of this work is Emanuele Nardi

% Define Class Metadata
% ----------------------------------------------------------------------
% Provides information to the LaTeX3 compiler about what our class does.
\ProvidesExplClass{unitnthesis}
                  {2024/12/23}% starting date: 2024/11/28
                  {0.5.0}
                  {LaTeX3 class for Academic Theses at the University of Trento (UniTN).}

\bool_new:N \g__unitnthesis_draft_bool
\bool_new:N \g__unitnthesis_debug_bool

% Error messages
% ----------------------------------------------------------------------
\msg_new:nnn { unitnthesis } { language-set } {
  language~set~to~"#1".
}

\msg_new:nnn { unitnthesis } { unknown-language-option } {
  % \msg_warning_text:n { unitnthesis } \iow_newline:
  \bool_if:NTF \l__unitnthesis_language_italian_bool
    {Opzione~language~sconosciuta:~"#1",~valori~accettati:~[italian/english].}
    {Unknown~language~option:~"#1",~accepted~values~are:~[italian/english].}
}

\msg_new:nnn { unitnthesis } { passing-unknown-options } {
  Passing~option~"#1"~to~class~book.
}

% class options
% ----------------------------------------------------------------------
\keys_define:nn { unitnthesis / global } {
  draft .usage:n = load,
  draft .code:n =
    {
        \bool_gset_true:N \g__unitnthesis_draft_bool
        \PassOptionsToClass { draft } { book }
    },
  draft .default:n  = { true },  % "draft" -> "draft = true"
  draft .initial:n  = { false }, % not specified  -> "draft = false"
  debug .usage:n = load,
  debug .bool_gset:N = \g__unitnthesis_debug_bool,
  debug .default:n = { true },   % "debug" -> "debug = true"
  debug .initial:n = { false },  % not specified  -> "debug = false"
  % I should manage explicitely the language option as egreg suggested me
  % Shortcuts
  % italian .meta:n = { language = italian },
  % english .meta:n = { language = italian },
  % Language for typesetting the frontispiece
  language .usage:n = load,
  language .choice:,
  language / italian .code:n = 
    {
      \bool_set_true:N \l__unitnthesis_language_italian_bool
      \tl_gset:Nn \g__unitnthesis_language_main_tl { italian }
      \msg_info:nne { unitnthesis } { language-set } { #1 }
      % \typeout{Class~unitnthesis~info:~g__unitnthesis_language_main_tl~=~\g__unitnthesis_language_main_tl}
    },
  language / english .code:n = 
    {
      \bool_set_false:N \l__unitnthesis_language_italian_bool
      \tl_gset:Nn \g__unitnthesis_language_main_tl { english }
      \msg_info:nne { unitnthesis } { language-set } { #1 }
      % \typeout{Class~unitnthesis~info:~g__unitnthesis_language_main_tl~=~\g__unitnthesis_language_main_tl}
    },
  language .initial:n = italian,
  language / unknown .code:n = \msg_error:nne { unitnthesis } { unknown-language-option } { #1 },
  unknown .code:n = {
    \msg_info:nne { unitnthesis } { passing-unknown-options } { \CurrentOption }
    % for example: 10pt, 11pt, 12pt -> book
    \PassOptionsToClass { \CurrentOption } { book }
  }
}

% Keys created before the use of \ProcessKeyOptions act as package options.
\ProcessKeyOptions [ unitnthesis / global ]

% Loading base class
\LoadClass [ a4paper ] { book }
% lose the constraint on equalising page content
\raggedbottom

% Essential packages
% ----------------------------------------------------------------------
\RequirePackage{geometry}
\RequirePackage{tabularray}% needed for table on the frontispiece
\RequirePackage{graphicx}% needed for university logo

% Support variables for defined functions
% ----------------------------------------------------------------------
% \tl_new:N \g__unitnthesis_language_main_tl
% \tl_gset:Nn \g__unitnthesis_language_main_tl { italian }% valore predefinito
% \bool_new:N \l__unitnthesis_language_italian_bool

% Error messages
% ----------------------------------------------------------------------
\msg_new:nnn { switchcase } { no-department-match } {
    % \msg_warning_text:n { unitnthesis } \iow_newline:
    \bool_if:NTF \l__unitnthesis_language_italian_bool
      {Il~dipartimento~"#1"~non~esiste!}
      {The~department~"#1"~doesn't~exist!}
}

\msg_new:nnn { unitnthesis } { unknown-chapter-style } {
    % \msg_warning_text:n { unitnthesis } \iow_newline:
    \bool_if:NTF \l__unitnthesis_language_italian_bool
      {Stile~capitolo~"#1"~sconosciuto.}
      {Unknown~chapter~style~"#1".}
}

\msg_new:nnn { unitnthesis } { page-count-exceeded } {
  % \msg_warning_text:n { unitnthesis } \iow_newline:
  % qui ricordati di passare la differenza fra le pagine massime e quelle stampate
  \bool_if:NTF \l__unitnthesis_language_italian_bool
    {Il~conteggio~delle~pagine~è~#1,~ha~superato~il~limite~di~#2.}
    {The~page ~count~is~#1,~it~has~exceeded~the~limit~by~#2.}
}

% Variables
% ----------------------------------------------------------------------
\int_new:N \g__unitnthesis_page_count_int
\int_new:N \g__unitnthesis_page_count_max_int

% internal structures within the class
% ----------------------------------------------------------------------
\prop_new:N \l__unitn_attributes_prop % Needed for conversion from department acronym to full string

% Define class options
% It defines user commands with default values for user data 
% It provides user-facing interface to document commands
% ----------------------------------------------------------------------
% cfr: only allow setting at load or in preamble - or define this after processing the options if you only want to let them set it in the preamble proper
% Options defined in the preamble through the \unitnset command
% ----------------------------------------------------------------------
\keys_define:nn { unitnthesis / setup }
  {
    % Department where the student is enrolled
    department .usage:n = preamble,
    department .code:n = \str_set:Ne \l__unitn_department_str { \str_casefold:n {#1} },
    department .value_required:n = true,
    department .initial:n = { disi },
    % Degree the student is graduating with
    degree .code:n = \str_set:Ne \l__unitn_degree_str { \str_casefold:n {#1} },
    degree .usage:n = preamble,
    degree .value_required:n = true,
    degree .initial:n = { bachelor },
    % Course name or program the student is completing
    course .usage:n = preamble,
    course .str_set:N = \l__unitn_course_tl,
    course .value_required:n = true,
    course .initial:n = { Course~Name },
    % Main title of the document (e.g., thesis title)
    title .usage:n = preamble,
    title .tl_set:N = \l__unitn_title_tl,
    title .value_required:n = true,
    title .initial:n = { Thesis~Title },
    % Subtitle of the thesis
    subtitle .usage:n = preamble,
    subtitle .tl_set:N = \l__unitn_subtitle_tl,
    subtitle .value_required:n = true,
    subtitle .initial:n = { Subtitle~(usually~longer~and~optional) },
    % List of keywords related to the thesis's topic
    keywords .usage:n = preamble,
    keywords .clist_set:N = \l__unitn_keywords_clist,
    keywords .value_required:n = false,
    keywords .initial:n = {},% empty csv list
    % Shortcut: candidate -> candidate/name
    candidate .usage:n = preamble,
    candidate .value_required:n = true,
    candidate .meta:n = { candidate / name = #1 },
    % candidate label
    candidate / label .usage:n = preamble,
    candidate / label .tl_set:N = \l__unitn_candidate_label_tl,
    candidate / label .initial:n = { Candidato },
    % Name of the candidate (the student)
    candidate / name .usage:n = preamble,
    candidate / name .tl_set:N = \l__unitn_candidate_tl,
    candidate / name .value_required:n = true,
    % Student's identification number
    candidate / ID .usage:n = preamble,
    candidate / ID .tl_set:N = \l__unitn_id_tl,
    candidate / ID .value_required:n = true,
    candidate / ID .initial:n = { 000000 },
    % advisor label
    advisor / label .usage:n = preamble,
    advisor / label .tl_set:N = \l__unitn_advisor_label_tl,
    advisor / label .value_required:n = true,
    advisor / label .initial:n = { Relatore },
    % Shortcut: advisor -> advisor/name
    advisor .usage:n = preamble,
    advisor .meta:n = { advisor / name = #1 },
    % Name of the candidate Name of the advisor/supervisor
    advisor / name .usage:n = preamble,
    advisor / name .tl_set:N = \l__unitn_advisor_tl,
    advisor / name .value_required:n = true,
    % advisor / name .initial:n = { Prof.\ Nome~Cognome },
    % advisor label
    coadvisors / label .usage:n = preamble,
    coadvisors / label .tl_set:N = \l__unitn_coadvisors_label_tl,
    coadvisors / label .value_required:n = true,
    coadvisors / label .initial:n = { Correlatore },
    % Shortcut: coadvisors -> coadvisors/name
    coadvisors .usage:n = preamble,
    coadvisors .meta:n = { coadvisors / names = { #1 } },% curly braces are important here!
    % Name of the co-advisors (if present)
    coadvisors / names .clist_set:N = \l__unitn_coadvisors_clist,
    coadvisors / names .usage:n = preamble,
    coadvisors / names .value_required:n = true,% is it mandatory to have a co-advisor?
    % coadvisors / names .initial:n = { Prof.\ Nome~Cognome },
    % Year of document submission or graduation
    year .usage:n = preamble,
    year .tl_set:N = \l__unitn_year_tl,
    year .value_required:n = true,
    year .initial:n = { 2024/2025 },
    % Optional dedication page
    dedication .usage:n = preamble,
    dedication .tl_set:N = \l__unitn_dedication_tl,
    dedication .value_required:n = false,
    dedication .initial:n = {},% empty string
    % chapther style
    chapther ~ style .usage:n = preamble,
    chapther ~ style .choice:,
    chapther ~ style / latex .tl_set:N = \l__unitnthesis_chapter_style_tl,
    chapther ~ style / compact .tl_set:N = \l__unitnthesis_chapter_style_tl,
    chapther ~ style / unknown .code:n = \msg_error:nne { unitnthesis } { unknown-chapter-style } { #1 },
    chapther ~ style .initial:n = latex,
    % checks if page count has exceeded manual limit
    page ~ limit .usage:n = preamble,
    page ~ limit .value_required:n = false,
    page ~ limit .tl_set:N = \g__unitnthesis_page_count_max_int,
    page ~ limit .initial:n = {-1},
    % keys that are not used anymore...
    % Shortcut: language -> language/main
    % language .usage:n = preamble,
    % candidate .code:n = { \keys_set:nn { unitnthesis / setup / candidate } {#1} },
    % language .meta:n = { \keys_set:nn { unitnthesis / setup / language } { #1 } },
    % language / other .usage:n = preamble,
    % language / other .code:n = {
    %     \clist_set:Nn \l__unitnthesis_language_other_clist { #1 }
    %     % \IfPackageLoadedTF{babel}{
    %     %     \PassOptionsToPackage{\clist_use:Nn \l__unitnthesis_language_other_clist {,}}{babel}
    %     % }{
    %     %     \typeout{please~load~the~babel~package}
    %     % }
    % },
    % language / other .initial:n = { english },  % if not specified "languages / other = { english }"
    % candidate / name .initial:n = { Nome~Cognome },
 }

% cfr: if you go with a key-val approach, you probably don't want students to have to set everything as a package option
% it provides a config command for use in the preamble
\NewDocumentCommand{\unitnset}{ +m }{
    \keys_set:nn { unitnthesis / setup } { #1 }
}

\NewDocumentCommand { \PrintDocumentation } { } {
  \noindent
  \begin{tblr}{
    colspec = {@{} Q[l] Q[l]},
    column{1} = {font=\ttfamily},
    row{1} = {c, font=\bfseries},
  }
    key              & value\\
    frontispiece     & \g__unitnthesis_language_main_tl\\
    localename       & \localename\\
    department       & \l__unitn_department_str\\
    dep.\ expanded   & \em\printDepartment\\
    degree           & \l__unitn_degree_str\\
    degree\ expanded & \em\bfseries\printDegree\\
    course           & \l__unitn_course_tl\\
    title            & \l__unitn_title_tl\\
    subtitle         & \l__unitn_subtitle_tl\\
    keywords         & \clist_use:Nn \l__unitn_keywords_clist {,~}\\
    candidate/label  & \em\bfseries\printCandidateLabel\\
    candidate/name   & \l__unitn_candidate_tl\\
    studentID        & \l__unitn_id_tl\\
    advisor/label    & \em\bfseries\printAdvisorLabel\\
    advisor/name     & \l__unitn_advisor_tl\\
    coadvisors/label & \em\bfseries\printAdvisorsLabel\\
    coadvisors/names & \clist_use:Nn \l__unitn_coadvisors_clist {,~}\\
    year             & \l__unitn_year_tl\\
    dedication       & \begin{tabular}{@{}l@{}}\tl_use:N \l__unitn_dedication_tl\end{tabular}\\
  \end{tblr}
}

% Personalized ifs
% ----------------------------------------------------------------------
\NewDocumentCommand{\ifItalian}{ m m }{%
    \bool_if:NTF \l__unitnthesis_language_italian_bool%
        {#1}% If italian
        {#2}% If english
}

% ----------------------------------------------------------------------
%                       Frontispiece configuration
% ----------------------------------------------------------------------
% "toString" in the frontispiece
% ----------------------------------------------------------------------
\NewDocumentCommand{\printDepartment}{}{
    \prop_item:Ne \l__unitn_attributes_prop { department @ \l__unitn_department_str @ \g__unitnthesis_language_main_tl }
}
% ----------------------------------------------------------------------
% "toString" in the frontispiece
% ----------------------------------------------------------------------
\NewDocumentCommand{\printDegree}{}{
    \prop_item:Ne \l__unitn_attributes_prop { degree @ \l__unitn_degree_str @ \g__unitnthesis_language_main_tl }
}

\NewDocumentCommand{\printCandidateLabel}{}{%
    
    \tl_use:N \l__unitn_candidate_label_tl%
}

\NewDocumentCommand{\printAdvisorLabel}{}{%
    \tl_use:N \l__unitn_advisor_label_tl%
}

\NewDocumentCommand{\printAdvisorsLabel}{}{%
    \tl_use:N \l__unitn_coadvisors_label_tl%
}

% a facility to set attributes
% ----------------------------------------------------------------------
\cs_new_protected:Nn \__unitn_attribute:nnnn {
    \prop_gput:Nnn \l__unitn_attributes_prop { #1 @ #2 @ italian } {#3}
    \prop_gput:Nnn \l__unitn_attributes_prop { #1 @ #2 @ english } {#4}
}

\group_begin:
% in order not to be forced to use ~, set locally the category code of the space to the standard value.
% ----------------------------------------------------------------------
\char_set_catcode_space:n {`\ }
% ----------------------------------------------------------------------
% https://www.unitn.it/ateneo/14/strutture
% ----------------------------------------------------------------------
% C3A - Centro Agricoltura, Alimenti, Ambiente
\__unitn_attribute:nnnn{department}{c3a}
  {Centro Agricoltura, Alimenti, Ambiente}
  {Center Agriculture Food Environment}
% CIBIO - Department Of Cellular, Computational and Integrative Biology
\__unitn_attribute:nnnn{department}{cibio}
  {Department Of Cellular, Computational and Integrative Biology}
  {Department of Cellular, Computational and Integrative Biology}
% CIMeC - Centro Interdipartimentale Mente/Cervello
\__unitn_attribute:nnnn{department}{cimec}
  {Centro Interdipartimentale Mente/Cervello}
  {Center for Mind/Brain Sciences}
% CISMed - Centro Interdipartimentale di Scienze Mediche
\__unitn_attribute:nnnn{department}{cismed}
  {Centro Interdipartimentale di Scienze Mediche}
  {Interdepartmental Center for Medical Sciences}
% dem - Dipartimento di Economia e Management
\__unitn_attribute:nnnn{department}{dem}
  {Dipartimento di Economia e Management}
  {Department of Economics and Management}
% df - Dipartimento di Fisica
\__unitn_attribute:nnnn{department}{df}
  {Dipartimento di Fisica}
  {Department of Physics}
% dfg - Dipartimento Facoltà Di Giurisprudenza
\__unitn_attribute:nnnn{department}{dfg}
  {Dipartimento Facoltà Di Giurisprudenza}
  {Department Faculty of Law}
% dicam - Dipartimento di Ingegneria Civile, Ambientale e Meccanica
\__unitn_attribute:nnnn{department}{dicam}
  {Dipartimento di Ingegneria Civile, Ambientale e Meccanica}
  {Department of Civil, Environmental and Mechanical Engineering}
% dii - Dipartimento di Ingegneria Industriale
\__unitn_attribute:nnnn{department}{dii}
  {Dipartimento di Ingegneria Industriale}
  {Department of Industrial Engineering}
% DIPSCO - Dipartimento di Psicologia e Scienze cognitive
\__unitn_attribute:nnnn{department}{dipsco}
  {Dipartimento di Psicologia e Scienze cognitive}
  {Department of Psychology And Cognitive Science}
% DISI - Dipartimento di Ingegneria e Scienza dell'Informazione
\__unitn_attribute:nnnn{department}{disi}
  {Dipartimento di Ingegneria e Scienza dell'Informazione}
  {Department of Information Engineering And Computer Science}
% dlf - Dipartimento di Lettere e Filosofia
\__unitn_attribute:nnnn{department}{dlf}
  {Dipartimento di Lettere e Filosofia}
  {Department of Humanities}
% dm - Dipartimento di Matematica
\__unitn_attribute:nnnn{department}{dm}
  {Dipartimento di Matematica}
  {Department of Mathematics}
% dsrs - Dipartimento di Sociologia e Ricerca Sociale
\__unitn_attribute:nnnn{department}{dsrs}
  {Dipartimento di Sociologia e Ricerca Sociale}
  {Department of Sociology and Social Research}
% SSI - Scuola di Studi Internazionali
\__unitn_attribute:nnnn{department}{ssi}
  {Scuola di Studi Internazionali}
  {School of International Studies}

\__unitn_attribute:nnnn{degree}{bachelor}{Laurea Triennale in}{Bachelor's Degree in}
\__unitn_attribute:nnnn{degree}{master}{Laurea Magistrale in}{Master's Degree in}
\__unitn_attribute:nnnn{degree}{doctorate}{Dottorato in}{Doctoral Programme in}

% restore the category code of the space for macros
% ----------------------------------------------------------------------
\group_end:

% Configuring specific parameters for each department
% ----------------------------------------------------------------------
% Margins change from department to department
% legend: ND = Not Defined in the department's guidelines
% ----------------------------------------------------------------------

% it handles if the specified department is typed incorrectly or it simply doesn't exist
\NewDocumentCommand{\switchcase}{ m m }{
    \str_case_e:nnF { #1 } { #2 } { \msg_error:nne { switchcase } { no-department-match } { #1 } }
}

% ----------------------------------------------------------------------
%                       Dynamic margin configuration
% ----------------------------------------------------------------------
\NewDocumentCommand{\departmentGeometry}{ m }{
    \switchcase{#1}{
        {c3a}    {\geometryDEFAULT}
        {cibio}  {\geometryDEFAULT}
        {cimec}  {\geometryDEFAULT}
        {cismed} {\geometryDEFAULT}
        {dem}    {\geometryDEFAULT}
        {df}     {\geometryDEFAULT}
        {dfg}    {\geometryDFG}
        {dicam}  {\geometryDEFAULT}
        {dii}    {\geometryDEFAULT}
        {dipsco} {\geometryDEFAULT}
        {disi}   {\geometryDISI}
        {dlf}    {\geometryDEFAULT}
        {dm}     {\geometryDEFAULT}
        {dsrs}   {\geometryDSRS}
        {ssi}    {\geometryDEFAULT}
    }
}

% ----------------------------------------------------------------------
%                     Configuring dynamic line spacing
% ----------------------------------------------------------------------
\NewDocumentCommand{\departmentSpacing}{ m }{
    \switchcase{#1}{
        {c3a}    {\spacingDEFAULT}
        {cibio}  {\spacingDEFAULT}
        {cimec}  {\spacingDEFAULT}
        {cismed} {\spacingDEFAULT}
        {dem}    {\spacingDEFAULT}
        {df}     {\spacingDEFAULT}
        {dfg}    {\spacingDEFAULT}
        {dicam}  {\spacingDEFAULT}
        {dii}    {\spacingDEFAULT}
        {dipsco} {\spacingDEFAULT}
        {disi}   {\spacingDEFAULT}
        {dlf}    {\spacingDEFAULT}
        {dm}     {\spacingDEFAULT}
        {dsrs}   {\spacingDSRS}
        {ssi}    {\spacingDEFAULT}
    }
}

% ----------------------------------------------------------------------
%               Configuring dynamic paragraph skippping
% ----------------------------------------------------------------------
\NewDocumentCommand{\departmentParskip}{ m }{
    \switchcase{#1}{
        {c3a}    {\parskipDEFAULT}
        {cibio}  {\parskipDEFAULT}
        {cimec}  {\parskipDEFAULT}
        {cismed} {\parskipDEFAULT}
        {dem}    {\parskipDEFAULT}
        {df}     {\parskipDEFAULT}
        {dfg}    {\parskipDFG}
        {dicam}  {\parskipDEFAULT}
        {dii}    {\parskipDEFAULT}
        {dipsco} {\parskipDEFAULT}
        {disi}   {\parskipDEFAULT}
        {dlf}    {\parskipDEFAULT}
        {dm}     {\parskipDEFAULT}
        {dsrs}   {\parskipDEFAULT}
        {ssi}    {\parskipDEFAULT}
    }
}

% c3a:
% cibio:
% cimec:
% cismed:
% dem:
% df:
% dfg: top = 3cm, bottom = 3cm, inner = 3cm, outer = 3cm
% dicam:
% dii:
% dipsco:
% disi: top = 2.5cm, bottom = 2.5cm, inner = 2cm, outer = 1.5cm
% dlf:
% dm:
% dsrs: top = ND, bottom = ND, inner = 3cm, outer = 3cm
% ssi:
\RequirePackage{geometry}
\newcommand{\geometryDEFAULT}{\geometry{top = 2cm, bottom = 2cm, inner = 2.5cm, outer = 1.5cm}}
\newcommand{\geometryDISI}{\geometry{top = 2.5cm, bottom = 2.5cm, inner = 2cm, outer = 1.5cm}}
\newcommand{\geometryDSRS}{\geometry{top = 2.5cm, bottom = 2.5cm, inner = 3cm, outer = 3cm}}
\newcommand{\geometryDFG}{\geometry{top = 3cm, bottom = 3cm, inner = 3cm, outer = 3cm}}

% c3a:
% cibio:
% cimec:
% cismed:
% dem:
% df:
% dfg:  \singlespacing
% dicam:
% dii:
% dipsco:
% disi: \singlespacing
% dlf:
% dm:
% dsrs: \onehalfspacing
% ssi:
\RequirePackage{setspace}
\newcommand{\spacingDEFAULT}{\singlespacing}
\newcommand{\spacingDSRS}{\onehalfspacing}

% c3a:
% cibio:
% cimec:
% cismed:
% dem:
% df:
% dfg: indent first line by 1cm
% dicam:
% dii:
% dipsco:
% disi: ND
% dlf:
% dm:
% dsrs: 
% ssi:
\newcommand{\parskipDFG}{\RequirePackage{indentfirst}\setlength{\parindent}{1cm}}
\newcommand{\parskipDEFAULT}{\RequirePackage[parfill]{parskip}}

% call to the functions once the user sets the department manually
\AddToHook{ begindocument / before }{
    \departmentGeometry{\str_use:N \l__unitn_department_str}
    \departmentParskip{\str_use:N \l__unitn_department_str}
    % \departmentSpacing is called after issuing the \mainmatter command in the main body of the text
}

% ----------------------------------------------------------------------
%                       set main font 
% ----------------------------------------------------------------------
\AddToHook{ begindocument / before }{
    \switchcase{\str_use:N \l__unitn_department_str}{
        {c3a}    {}
        {cibio}  {}
        {cimec}  {}
        {cismed} {}
        {dem}    {}
        {df}     {}
        {dfg}    {}
        {dicam}  {}
        {dii}    {}
        {dipsco} {}
        {disi}   {}
        {dlf}    {}
        {dm}     {}
        {dsrs}{
            % cfr: if it cannot be avoided, use a better configuration and make it engine sensitive
            \sys_if_engine_pdftex:T
              {
                \RequirePackage[scaled]{helvet}% font changed to Helvetica
                \renewcommand{\familydefault}{\sfdefault}
              }
            \sys_if_engine_luatex:T
              {
                \RequirePackage{fontspec}
                % \setmainfont{Helvetica}% TeX Gyre Heros is the preinstalled font alternative
                % see: https://tex.stackexchange.com/a/482538/127473
                \defaultfontfeatures{Scale = MatchLowercase}
                \setmainfont{TeX Gyre Heros}[Scale = 1.0]
              }
        }
        {ssi}    {}
    }
}

% Save the original \mainmatter definition
% Redefine \mainmatter to include additional code
\hook_gput_code:nnn { cmd / mainmatter / after } { . }
  {
    \departmentSpacing{\str_use:N \l__unitn_department_str}
    % \pagestyle{plain}
  }

% Save the original \mainmatter definition
% Redefine \mainmatter to include additional code
\hook_gput_code:nnn { cmd / backmatter / after } { . }
  {
    % reset spacing for \backmatter material
    \singlespacing
  }

% ----------------------------------------------------------------------
%                          Empty pages
% ----------------------------------------------------------------------
% removes headers and footers on empty pages between chapters
% ----------------------------------------------------------------------
\RequirePackage{emptypage}

% ----------------------------------------------------------------------
%                 Redefinitions of parts of the theses
% ----------------------------------------------------------------------
\str_if_eq:nVT {compact} \l__unitnthesis_chapter_style_tl
  {
    \RequirePackage{titlesec}
    % NOTE ridefinizione del formato del titolo del capitolo
    \titleformat{\chapter}
    	{\normalfont\Huge\bfseries}{\thechapter}{1em}{}
    % Appendix A -> A
    % Chapter 1 -> 1
    
    % changes the space before and after the environment
    \titlespacing*{\chapter}{0pt}{0.59in}{0.02in}
    \titlespacing*{\section}{0pt}{0.20in}{0.02in}
    \titlespacing*{\subsection}{0pt}{0.10in}{0.02in}  
  }

% ----------------------------------------------------------------------
%                           appendix
% ----------------------------------------------------------------------
\RequirePackage[titletoc, toc, title]{appendix}
% patch italian translation in toc
\ifItalian{\renewcommand{\appendixtocname}{Appendici}}{}

% ----------------------------------------------------------------------
%                           Table of Contents
% ----------------------------------------------------------------------
% Automatically adds the bibliography and/or the index and/or the contents, etc., to the Table of Contents 
% ----------------------------------------------------------------------
\RequirePackage[nottoc, notlof, notlot]{tocbibind}

% draft mode
% ----------------------------------------------------------------------
\bool_if:NT \g__unitnthesis_draft_bool
  {
  }

% Debug mode
% ----------------------------------------------------------------------
\bool_if:NT \g__unitnthesis_debug_bool
  {
  \sys_if_engine_luatex:TF
    {
      \RequirePackage{lua-visual-debug}
    }
    {
      % inspired by lua-visual-debug
      % 1. show margin limits on every page
      \RequirePackage{showframe}
      \renewcommand\ShowFrameLinethickness{1pt}
      \renewcommand*\ShowFrameColor{\color{teal}}
  
      % 2. show labels on the margins
      \RequirePackage{showkeys}
      \providecommand*\showkeyslabelformat[1]{%
          \fbox{\normalfont\small\ttfamily#1}}
  
      % 3. disable patch for microtype, it simply removes an unuseful warning
      \RequirePackage{microtype}
      \microtypesetup{nopatch=eqnum}
      
      % 4. whenever a line of text exceeds the page's width
      \setlength\overfullrule{5pt}
  
      % 5. draws all hlines and vlines for all tblr tables
      \RequirePackage{tabularray}
      \SetTblrInner{hlines={teal!50},vlines={teal!50}}
  
      % 6. Redefine the \includegraphics command to automatically include a frame option for all images
      \RequirePackage[export]{adjustbox}
      \let\oldincludegraphics\includegraphics
      \renewcommand{\includegraphics}[2][]{%
          \oldincludegraphics[frame,#1]{#2}%
      }
    }
  }

% ----------------------------------------------------------------------
% Checks for maximum no. of pages and print warning if limit is exceeded
% ----------------------------------------------------------------------

\AddToHook{ shipout / after }{
    % (global) Increases the value stored in \g__unitnthesis_page_count_int by 1.
    \int_gincr:N \g__unitnthesis_page_count_int
}

\AddToHook{ enddocument / afterlastpage }{
    % how do I test if a int key as a value associated with it
    \int_compare:nNnF {\g__unitnthesis_page_count_max_int} = {-1}
      {
        \int_compare:nNnT {\g__unitnthesis_page_count_int} > {\g__unitnthesis_page_count_max_int} {
          \msg_warning:nnVV { unitnthesis } { page-count-exceeded }
            {\g__unitnthesis_page_count_int}
            {\g__unitnthesis_page_count_max_int}
        }
      }
}

% ----------------------------------------------------------------------
%                           Custom Environments
% ----------------------------------------------------------------------

% Creating the title page
% ----------------------------------------------------------------------
\RenewDocumentCommand{ \maketitle }{}{
  \begin{titlepage}
    \centering

    % just a test fro different logo (doubledegree for example)
    % \str_if_eq:VnT \l__unitn_department_str {disi}
      % {
        \includegraphics[width=0.4\textwidth]{assets/images/logo/marchio-unitrento-colore-it}\par
        \noindent\rule{\textwidth}{0.1pt}\par
        {\textsc{\printDepartment}\par}
      % }
    
    \vspace{\stretch{2}}
    {\Large
        % avoids "There's no line here to end." error if \degree{} is issue without any specification
        \printDegree\str_if_empty:NF \l__unitn_degree_str {\\}
        \tl_use:N \l__unitn_course_tl
    \par}
    
    \vspace{\stretch{2}}
    {\Large \textsc{\ifItalian{Elaborato~Finale}{Final~Dissertation}}\par}
    
    \vspace{\stretch{1}}
    {\Huge \textsc{\tl_use:N \l__unitn_title_tl}\par}
    
    {\Large \textsc{\tl_use:N \l__unitn_subtitle_tl}\par}
    
    \vspace{\stretch{5}}
    % TODO cfr: substitute a regular tabular of some kind 
    % TODO cfr: if users use overleaf, they have very, very limited capacity for this type of table.
    % TODO cfr: don't use up their processing time on the titlepage 
    % TODO cfr: I don't use tabularray, but there is nothing here you can't do with tabularx or tabular*
    \begin{tblr}{
        width = .9\textwidth,
        colspec = {Q[l] X Q[l]},
        stretch = 0.75,
        row{1,3} = {c, font=\bfseries},
        row{3} = {abovesep+ = 6pt},% additional space before 'Co-Supervisor'
    }

    % either use the pattern above or test at the end of the preamble to ensure babel is loaded and use babel extras to set up suitable macros here
    \printAdvisorLabel && \printCandidateLabel \\
    \tl_use:N \l__unitn_advisor_tl && \tl_use:N \l__unitn_candidate_tl\\
    \tl_if_blank:eF \l__unitn_coadvisors_clist
        {\printAdvisorsLabel}\\
    \tl_if_blank:eF \l__unitn_coadvisors_clist
        {\begin{tabular}{@{} l @{}}
            \clist_use:Nn \l__unitn_coadvisors_clist {\\}
        \end{tabular}}
    \end{tblr}\par

    \vspace{\stretch{4}}
    {\Large
    \tl_if_blank:eF \l__unitn_year_tl
      {\ifItalian{Anno~Accademico}{Academic~Year}~\tl_use:N \l__unitn_year_tl\par}%
    }
  \end{titlepage}
  % print values of the frontispiece for debugging purposes
  \bool_if:NT \g__unitnthesis_debug_bool { \PrintDocumentation }
  % Optional dedication page
  \tl_if_empty:NF { \l__unitn_dedication_tl } {
    \cleardoublepage
    \thispagestyle{empty}

    % NOTE spaziatura di un 1/5 della pagina
    \vspace*{\stretch{1}}
    \begin{flushright}\em\large
    \tl_use:N \l__unitn_dedication_tl
    \end{flushright}
    
    % NOTE spaziatura di un 4/5 della pagina
    \vspace*{\stretch{4}}
  }
  \newpage
  % If the department is {dfg} then print the 5 required keywords on the second page
  \str_if_eq:VnT \l__unitn_department_str {dfg}
    {\noindent\textbf{\ifItalian{Parole~chiave}{Keywords}}:~\clist_use:Nn \l__unitn_keywords_clist {,~}}
}

% % ----------------------------------------------------------------------
% %                           Abstract paragraph
% % ----------------------------------------------------------------------
% \NewDocumentEnvironment{ abstract }{}
% {
%   \chapter*{\ifItalian{Sommario}{Abstract}}
% }{\par}

% % Define abstract environment.
% \NewDocumentEnvironment { abstract } { O{\textwidth} } {
%   \begin{minipage}[t]{#1}
%   \setlength{\parindent}{15pt}
%   \noindent
% } {
%   \end{minipage}
% }

% % ----------------------------------------------------------------------
% %                           Acknowledgements page
% % ----------------------------------------------------------------------
% \NewDocumentEnvironment{ acknowledgements }{}
% {
%     \chapter*{\ifItalian{Ringraziamenti}{Acknowledgements}}
%     \thispagestyle{empty}
    
%     \em% make the text cursive
% }{\par}

% ----------------------------------------------------------------------
%                Everything that needs to go at end of preamble
% ----------------------------------------------------------------------
% cfr: if you just \RequirePackage here, it is at the end of the class - not the preamble
% you need things in hooks to delay them
% TODO cfr: do this ONLY if it is an institutional requirement
\hook_gput_code:nnn { begindocument/before }{ . }
{
    \IfPackageLoadedTF{ hyperref }{}
    {
        \RequirePackage{bookmark}
    }
    \hypersetup{
        hidelinks,% hides the default boxes around links
        linktoc=all,% makes both the reference text and page number
        pdfinfo = {
            Title={\tl_use:N \l__unitn_title_tl},
            Author={\tl_use:N \l__unitn_candidate_tl},
            Subject={\tl_use:N \l__unitn_title_tl},% argomento trattato
            Keywords={\clist_use:Nn \l__unitn_keywords_clist {,~}},
        }
    }
}

% End of class 'unitnthesis'