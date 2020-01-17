defmodule LunchWeb.ErrorView do
  use LunchWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  #
  # credo:disable-for-next-line Credo.Check.Readability.Specs
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  @spec alert_component(Ecto.Changeset.t() | any) :: String.t() | iolist
  def alert_component(%{action: action}) when is_nil(action), do: ""

  def alert_component(_) do
    content_tag(
      :div,
      content_tag(:p, gettext("Oops, something went wrong! Please check the errors below.")),
      class: "alert alert-danger"
    )
  end
end
