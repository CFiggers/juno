#let body(doc) = {
    set page ( 
        paper: "us-letter",
        margin: (x: 1in, top: 1in, bottom: 0.9in),
        footer: [
            #let cell = rect.with(
                width: 100%,
                stroke: none
            )

            #let timestamp = locate(loc => 
                "[" 
                + str(calc.floor(counter(page).at(loc).first() * 3.5))
                + ":00]"
            )

            #grid(
                columns: (33%, 33%, 40%),
                rows: (auto),
                gutter: 3pt,
                cell[],
                cell[
                    #align(center)[#counter(page).display("1")]
                ],
                cell[
                    #align(right)[#timestamp]
                ]
            )
        ]
    )

    show heading.where(level:1): it => [
        #set block(
            below: 1.65em
        )
        #set text(12pt, 
            weight: "bold",
            font: "Times New Roman")
        #block(it.body)
    ]

    show heading.where(level:2): it => [
        #set block(
            below: 1.65em
        )
        #set text(12pt, 
            style: "italic",
            font: "Times New Roman")
        #block(it.body)
    ]

    show heading.where(level:3): it => [
        #set block(
            below: 1.65em
        )
        #set text(12pt, 
            style: "italic",
            weight: "regular",
            font: "Times New Roman")
        #block(it.body)
    ] 
    
    set list(
        indent: 1.65em
    )
                                
    set enum( 
        indent: 1.65em
    )

    set par(
        leading: 0.5em
    )

    set block(
        below: 1.65em
    )

    set text(
        font: "Times New Roman",
        size: 12pt
    )

    doc
} 

#let blockquote(body) = box(inset: (x: 1.65em, y: 0pt), width: 100%, {
  set text(style: "italic")
  body
})

#let poetry(body) = box(inset: (x: 1.65em, y: 0pt), width: 100%, {
  set text(style: "italic")
  set align(center)
  set block(spacing: 0.5em)
  body
})
                                   
#let indent(body) = box(
    inset: (x: 1.65em, y:0pt), width: 100% + 1.65em,
    {
        body
    }
) 