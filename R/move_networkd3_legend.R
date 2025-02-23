#' Add a responsive legend to a networkD3 plot with vertical or horizontal orientation
#'
#' This function allows you to dynamically position the legend of a networkD3 plot.
#' The legend is positioned as a percentage of the x and y coordinates relative to the
#' size of the plot. In addition, you can choose whether the legend items are arranged
#' vertically (default) or horizontally.
#'
#' @param netd3 An object of class \code{networkD3} (specifically a \code{forceNetwork}).
#' @param x_pos `numeric`. A numeric value between 0 and 1 that defines the horizontal position of the legend.
#'        0 is the far left, and 1 is the far right of the plot. Default is 0.85.
#' @param y_pos `numeric`. A numeric value between 0 and 1 that defines the vertical position of the legend.
#'        0 is the top, and 1 is the bottom of the plot. Default is 0.5 (centered).
#' @param legend_spacing `numeric`. A numeric value controlling the spacing between legend items (pixels). Default is 25 px.
#' @param align `character`. A character string controlling the horizontal alignment of the legend items.
#'        Possible values are "left", "center", and "right". Default is "left".
#' @param orientation `character`. A character string for the legend layout. Either "vertical" (default)
#'        or "horizontal".
#'
#' @return A \code{networkD3} object with the legend positioned according to the specified options.
#'
#' @examples
#' library(networkD3)
#' nodes <- data.frame(name = c("A", "B", "C", "D", "E", "F"))
#' links <- data.frame(source = c(0, 1, 2, 3, 4),
#'                     target = c(1, 2, 3, 4, 5),
#'                     value = c(1, 1, 1, 1, 1))
#'
#' netd3 <- forceNetwork(Links = links, Nodes = nodes,
#'                       Source = "source", Target = "target",
#'                       Value = "value", NodeID = "name",
#'                       legend = TRUE, Group = "name")
#'
#' # Vertical legend (default)
#' netd3_v <- move_networkd3_legend(netd3, x_pos = 0.2, y_pos = 0.3, legend_spacing = 35)
#'
#' # Horizontal legend
#' netd3_h <- move_networkd3_legend(netd3, x_pos = 0.4, y_pos = 1, orientation = "horizontal")
#'
#' @export
move_networkd3_legend <- function(netd3, x_pos = 0.85, y_pos = 0.5,
                                  legend_spacing = 25, align = "left",
                                  orientation = "vertical") {
  # Validate input parameters
  if (!inherits(netd3, "htmlwidget")) {
    stop("The provided object is not an htmlwidget, it must be a networkD3 object with an additionnal htmlwidget")
  }
  if (!inherits(netd3, "forceNetwork")) {
    stop("The provided object is not of class forceNetwork.")
  }
  if (x_pos < 0 || x_pos > 1 || y_pos < 0 || y_pos > 1) {
    message("x_pos and y_pos must be values between 0 and 1.")

    x_pos <- 0.5; y_pos = 0.5
  }
  if (!align %in% c("left", "center", "right")) {
    message("align must be one of 'left', 'center', or 'right'.")
    align <- "left"
  }
  if (!orientation %in% c("vertical", "horizontal")) {
    message("orientation must be either 'vertical' or 'horizontal'.")
    orientation <- "vertical"
  }

  netd3 <- htmlwidgets::onRender(netd3, sprintf("
    function(el) {
      var svg = d3.select(el).select('svg');
      var width = +svg.attr('width');
      var height = +svg.attr('height');
      var legend = svg.selectAll('.legend');
      var legend_spacing = %f;
      var orientation = '%s';

      if (orientation === 'horizontal') {
        // Calculate total width and maximum height of legend items
        var totalWidth = 0, maxHeight = 0;
        legend.each(function() {
          var bbox = this.getBBox();
          totalWidth += bbox.width + legend_spacing;
          if (bbox.height > maxHeight) { maxHeight = bbox.height; }
        });
        totalWidth -= legend_spacing; // Remove extra spacing at the end

        // Compute initial positions based on container dimensions
        var xPos = width * %f;
        var yPos = (height - maxHeight) * %f;

        // Adjust horizontal alignment
        if ('%s' === 'center') {
          xPos -= totalWidth / 2;
        } else if ('%s' === 'right') {
          xPos -= totalWidth;
        }

        // Position legend items horizontally
        var cumulativeWidth = 0;
        legend.each(function() {
          var bbox = this.getBBox();
          d3.select(this).attr('transform', 'translate(' + (xPos + cumulativeWidth) + ',' + yPos + ')');
          cumulativeWidth += bbox.width + legend_spacing;
        });
      } else {
        // Vertical orientation: calculate total height and maximum width
        var totalHeight = 0, maxWidth = 0;
        legend.each(function() {
          var bbox = this.getBBox();
          totalHeight += bbox.height + legend_spacing;
          if (bbox.width > maxWidth) { maxWidth = bbox.width; }
        });
        totalHeight -= legend_spacing; // Remove extra spacing at the end

        // Compute initial positions based on container dimensions
        var xPos = width * %f;
        var yPos = (height - totalHeight) * %f;

        // Adjust horizontal alignment for vertical layout
        if ('%s' === 'center') {
          xPos -= maxWidth / 2;
        } else if ('%s' === 'right') {
          xPos -= maxWidth;
        }

        // Position legend items vertically
        legend.each(function(d, i) {
          d3.select(this).attr('transform', 'translate(' + xPos + ',' + (yPos + i * (legend_spacing)) + ')');
        });
      }

      // Optionally adjust the viewBox to ensure the legend is visible
      svg.attr('viewBox', '-100 -100 ' + (width + 200) + ' ' + (height + 200) + ')');
    }
  ", legend_spacing, orientation,
                                                x_pos, y_pos, align, align, # // horizontal branch parameters
                                                x_pos, y_pos, align, align))  # vertical branch parameters

  return(netd3)
}
