locals {
  # Get a list of all the JSON files in the templates directory
  template_files = fileset("../templates/", "*.json")

  # Decode all the templates
  templates_data = { for f in local.template_files : f => jsondecode(file("./templates/${f}")) }
}

resource "aws_ses_template" "example" {
  for_each = local.templates_data

  name    = each.value.Template.TemplateName
  subject = each.value.Template.SubjectPart
  html    = each.value.Template.HtmlPart
  text    = each.value.Template.TextPart
}
