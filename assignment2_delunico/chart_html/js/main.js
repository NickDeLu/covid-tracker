///////////////////////////////////////////////////////////////////////////////
// main.js
// =======
// main entry point of test_chart
//
//  AUTHOR: Song Ho Ahn(song.ahn@gmail.com)
// CREATED: 2021-11-03
// UPDATED: 2022-11-15
///////////////////////////////////////////////////////////////////////////////


// global vars
go = {};

///////////////////////////////////////////////////////////////////////////////
// main entry point
document.addEventListener("DOMContentLoaded", e =>
{
    log("page loaded");
    //log.hide() // you can hide the log window
 
    // generate data object for line graph
    let dataset = {
        xs: ["A", "B", "C", "D", "E"],  // x-values
        ys: [0,   10,  50,  20,  40]    // y-values
    };

    // draw line graph
    drawChart(dataset);
});




///////////////////////////////////////////////////////////////////////////////
function drawChart(dataset, title)
{
    // remove the previous chart if exists
    if(go.chart)
        go.chart.destroy();

    // get 2D rendering context from canvas
    let context = document.getElementById("chart").getContext("2d");

    // create new chart object
    go.chart = new Chart(context,
    {
        type: "line",                   // type of chart
        data:
        {
            labels: dataset.xs,         // data for x-axis
            datasets:
            [{
                data: dataset.ys,       // y-values to plot
                lineTension: 0,         // no Bezier curve
                borderColor: "#4f9cf7", // line color
                borderWidth:2,
                backgroundColor: "rgba(189,221,255,0.5)",
                pointRadius:3,
                fill:true,
            }]
        },
        options:
        {
            maintainAspectRatio: false, // for responsive
            plugins:
            {
                title:
                {
                    display: true,
                    text: title // title for the chart
                },
                legend:
                {
                    display: false
                }
            }
        }
    });

    // debug
    log("X: " + dataset.xs);
    log("Y: " + dataset.ys);
    log(); // blank line
}
