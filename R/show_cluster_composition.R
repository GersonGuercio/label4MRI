#' @title
#' Show brain cluster composition
#' @description
#' Input a matrix of all MNI coordinates within a cluster, and output
#' the cluster composition (i.e., percentage of each brain region within it).
#' @param coordinate_matrix A matrix of the size 3 x N, which N is the number of
#' coordinates with the cluster of interest. Three rows correspond to the
#' x, y, z MNI values of each coordinate.
#' @param template One character vector which indicates the templates to use
#' (\code{"aal"} or \code{"ba"}). Use both of them by default.
#' @return
#' Return a list of frequency table and each of them corresponds to a template.
#' Each table consists the brain region names and the corresponding percentage
#' of the input brain cluster.
#'
#' If there are coordinates which do not fall into any labeled brain region
#' (e.g., white matter), it will be labeled as "NULL".
#' @seealso
#' \code{\link{show_nii_clusters}}
#' @examples
#' # Assume there is a cluster of brain coordinates that you want to know
#' # its composition.
#' # The cluster has 10 coordinates which MNI coordinates fall in the cube with
#' # min corner [10, 10, -5] and max cormer [15, 15, 0]
#' set.seed(1)
#' brain_matrix <- matrix(cbind(
#'   x = runif(n = 10, min = 10, max = 15),
#'   y = runif(n = 10, min = 10, max = 15),
#'   z = runif(n = 10, min = -5, max = 0)
#' ), nrow = 3, byrow = T)
#' show_cluster_composition(brain_matrix)
#' @export

show_cluster_composition <- function(coordinate_matrix, template = c("aal", "ba")) {

  # example matrix used: coordinate_matrix <- matrix(4:39, nrow = 3)
  if_template_exist <- template %in% names(label4mri_metadata)

  if (sum(!if_template_exist) != 0) {
    stop(paste0("Template `", paste(template[!if_template_exist], collapse = ", "), "` does not exist."))
  }

  list_frequency_table <-
    lapply(
      template,
      function(.template) {
        # Label the coordinate matrix
        labeled_coordinate_matrix <-
          mapply(
            FUN = mni_to_region_name,
            x = coordinate_matrix[1, ],
            y = coordinate_matrix[2, ],
            z = coordinate_matrix[3, ],
            distance = F,
            MoreArgs = list(template = .template)
          )

        # Create a frequency table of the coordinates of each brain region
        brain_frequency <-
          table(unlist(labeled_coordinate_matrix[paste0(.template, ".label"), ]))

        sorted_brain_frequency <-
          sort(brain_frequency, decreasing = T)

        # Add a column of percentate of each brain region
        sorted_brain_percentage <-
          round(sorted_brain_frequency / ncol(coordinate_matrix), 3) * 100

        sorted_table_frequency_percentage <-
          cbind(sorted_brain_frequency, sorted_brain_percentage)

        colnames(sorted_table_frequency_percentage) <-
          c("Number of coordinates", "Percentage (%)")

        sorted_table_frequency_percentage
      }
    )

  names(list_frequency_table) <- paste(template,
    "cluster",
    "composition",
    sep = "."
  )

  list_frequency_table
}
