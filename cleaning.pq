let
    Source = Csv.Document(File.Contents("C:\Users\hp\Desktop\Projects\SQL_Power_BI_Project_3_Netflix_Data_Cleaning_&_Analysis\netflix_titles.csv"),[Delimiter=",", Columns=12, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"show_id", type text}, {"type", type text}, {"title", type text}, {"director", type text}, {"cast", type text}, {"country", type text}, {"date_added", type date}, {"release_year", Int64.Type}, {"rating", type text}, {"duration", type text}, {"listed_in", type text}, {"description", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","","Not Available",Replacer.ReplaceValue,{"director", "cast", "country"}),
    #"Added Conditional Column" = Table.AddColumn(#"Replaced Value", "n", each if Text.Contains([rating], "min") then [rating] else if [duration] = "" then "No Duration" else [duration]),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "Custom", each if Text.Contains([rating], "min") then " No Rating" else if [rating] = "" then " No Rating" else [rating]),
    #"Removed Columns" = Table.RemoveColumns(#"Added Conditional Column1",{"rating", "duration"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"n", "duration"}, {"Custom", "rating"}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns",{"show_id", "type", "title", "director", "cast", "country", "date_added", "release_year", "duration", "rating", "listed_in", "description"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Reordered Columns",{{"show_id", type text}, {"type", type text}, {"title", type text}, {"director", type text}, {"cast", type text}, {"country", type text}, {"date_added", type date}, {"release_year", Int64.Type}, {"duration", type text}, {"rating", type text}, {"listed_in", type text}, {"description", type text}})
in
    #"Changed Type1"