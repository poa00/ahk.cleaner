; ======================================================================
;
;                  AHKcleaner - AutoHotkey Code Cleaner
;
;                              Version 1.2
;
;               Copyright 2015 / PB-Soft / Patrick Biegel
;
;                            www.pb-soft.com
;
; ======================================================================

; ======================================================================
; S P E C I F Y   T H E   A P P L I C A T I O N   S E T T I N G S
; ======================================================================

; Enable autotrim.
AutoTrim, On

; Make the application run at full speed.
SetBatchLines, -1

; Set the working directory.
SetWorkingDir, %A_ScriptDir%


; ======================================================================
; S P E C I F Y   T H E   A P P L I C A T I O N   I N F O R M A T I O N
; ======================================================================

; Specify the application name.
ApplName = AHKcleaner

; Specify the application version.
ApplVersion = 1.2


; ======================================================================
; I N I T I A L I Z E   V A R I A B L E S
; ======================================================================

; Initialize the comment flag.
CommentFlag = 0

; Initialize the copy counter.
CopyCounter = 0

; Initialize the line counter.
LineCounter = 0


; ======================================================================
; S E L E C T   A   S O U R C E   F I L E
; ======================================================================

; Open the file select dialog.
FileSelectFile, SourceFile, 3, %A_ScriptDir%, Please select an AutoHotkey source file !, AutoHotkey Source (*.ahk)

; Check if the user has selected a source file.
If SourceFile =
{

  ; Display an error message.
  MsgBox, 4112, %ApplName% %ApplVersion%, You did not select an AutoHotkey source file !

} ; Check if the user has selected a source file.

; The user has selected an AutoHotkey source file.
else
{


  ; ====================================================================
  ; S P E C I F Y   T H E   O U T P U T   F I L E N A M E
  ; ====================================================================

  ; Create the new filename.
  StringReplace, OutputFile, SourceFile, .ahk, _new.ahk


  ; ====================================================================
  ; D E L E T E   T H E   O L D   O U T P U T   F I L E
  ; ====================================================================

  ; Check if an old version of the cleaned source file exist.
  IfExist %OutputFile%
  {

    ; Delete the old version.
    FileDelete, %OutputFile%

  } ; Check if an old version of the cleaned source file exist.


  ; ====================================================================
  ; L O O P   T H R O U G H   T H E   S O U R C E   F I L E
  ; ====================================================================

  ; Loop through the AutoHotkey source file.
  Loop
  {


    ; ==================================================================
    ; I N I T I A L I Z E   V A R I A B L E S
    ; ==================================================================

    ; Initialize the copy flag.
    CopyFlag = 1


    ; ==================================================================
    ; R E A D   L I N E
    ; ==================================================================

    ; Read a line from the source file.
    FileReadLine, SourceLine, %SourceFile%, %A_Index%

    ; Increase the line counter.
    LineCounter++

    ; Check if there is an error.
    If ErrorLevel
    {

      ; Exit the loop.
      Break

    } ; Check if there is an error.


    ; ==================================================================
    ; T R I M   A N D   S T O R E   T H E   A C T U A L   L I N E
    ; ==================================================================

    ; Trim and store the actual line into a variable.
    ActualLine = %SourceLine%


    ; ==================================================================
    ; C H E C K   L I N E   F O R   R E G E X   P A T T E R N
    ; ==================================================================

    ; Check if there is a regex function in the actual line.
    IfNotInString, ActualLine, RegEx
    {


      ; ================================================================
      ; D E L E T E   S I N G L E   L I N E   C O M M E N T S
      ; ================================================================

      ; Delete single line comments.
      ActualLine := RegExReplace(ActualLine,"(?<!``);{1}.*","")


      ; ================================================================
      ; D E L E T E   M U L T I   L I N E   C O M M E N T   B E G I N
      ; ================================================================

      ; Initialize the regex counter.
      RegexCounter = 0

      ; Deletes multi line comments - Begin.
      ActualLine := RegExReplace(ActualLine,"(?<!``)/\*{1}.*","", RegexCounter)

      ; Check if a replacement was made.
      If RegexCounter > 0
      {

        ; Set the comment flag.
        CommentFlag = 1

      } ; Check if a replacement was made.


      ; ================================================================
      ; D E L E T E   M U L T I   L I N E   C O M M E N T S   E N D
      ; ================================================================

      ; Initialize the regex counter.
      RegexCounter = 0

      ; Deletes multi line comments - End.
      ActualLine := RegExReplace(ActualLine,".*\*/{1}","", RegexCounter)

      ; Check if a replacement was made.
      If RegexCounter > 0
      {

        ; Set the comment flag.
        CommentFlag = 0

      } ; Check if a replacement was made.


      ; ================================================================
      ; T R I M   T H E   A C T U A L   L I N E
      ; ================================================================

      ; Trim the actual line.
      ActualLine = %ActualLine%

    } ; Check if there is a regex function in the actual line.


    ; ==================================================================
    ; C H E C K   T H E   L I N E   I S   N O T   E M P T Y
    ; ==================================================================

    ; Check if the actual line is an empty line.
    If ActualLine =
    {

      ; Set the copy flag to zero.
      CopyFlag = 0

    } ; Check if the actual line is an empty line.


    ; ==================================================================
    ; S A V E   T H E   A C T U A L   L I N E
    ; ==================================================================

    ; Check if the actual line should be saved.
    If (CopyFlag = 1 && CommentFlag < 2)
    {

      ; Check if the comment flag is set to one. That means that it is
      ; the begin of a multiline comment. The actual line should be
      ; copied but the following lines not.
      If CommentFlag = 1
      {

        ; Increase the comment flag to 2 so that the following lines
        ; will not be copied.
        CommentFlag++

      } ; Check if the comment flag is set to one. That means...

      ; Reduce all space characters to one space character.
      ActualLine := RegExReplace(ActualLine, "\s+" ," ")

      ; Write the actual line to the new output file.
      FileAppend, %ActualLine%`n, %OutputFile%

      ; Increase the copy counter.
      CopyCounter++

    } ; Check if the actual line should be saved.

  } ; Loop through the AutoHotkey source file.


  ; ====================================================================
  ; D I S P L A Y   A N   I N F O R M A T I O N   M E S S A G E
  ; ====================================================================

  ; Specify the number format.
  SetFormat, float, 0.2

  ; Get the line difference in percent.
  LinePercent := (CopyCounter - LineCounter) / LineCounter * 100

  ; Get the source file size.
  FileGetSize, SizeSourceB, %SourceFile%

  ; Round the source file size.
  SizeSourceKB := SizeSourceB / 100

  ; Get the output file size.
  FileGetSize, SizeOutputB, %OutputFile%

  ; Round the output file size.
  SizeOutputKB := SizeOutputB / 100

  ; Get the size difference in percent.
  SizePercent := (SizeOutputB - SizeSourceB) / SizeSourceB * 100

  ; Calculate the number of removed lines.
  RemovedLines := LineCounter - CopyCounter

  ; Display an information message.
  MsgBox, 4160, %ApplName% %ApplVersion%, The cleaning was completed successfully !`n`nTotal lines: %LineCounter%`nCopied lines: %CopyCounter%`nRemoved lines: %RemovedLines%`nLine difference: %LinePercent% `%`n`nSource size: %SizeSourceKB% KB`nOutput size: %SizeOutputKB% KB`nSize difference: %SizePercent% `%

} ; The user has selected an AutoHotkey source file.


; ======================================================================
; E X I T   T H E   A P P L I C A T I O N
; ======================================================================
ExitApp
