using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.DataTypes
{
	public class PriceGroupControlFactory : IControlFactory, IControlAdapter
	{
		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName == GetType().Name.Replace("ControlFactory", "");
		}

		public Control GetControl(IProperty property)
		{
			var dropDownList = new SafeDropDownList();
			var priceGroups = PriceGroup.All().ToList();
			dropDownList.Items.Add(new ListItem { Text = "(auto)", Value = "0" });
			dropDownList.Items.AddRange(priceGroups.Select(pg => 
				new ListItem
				{
					Text = pg.Name, 
					Value = pg.PriceGroupId.ToString(CultureInfo.InvariantCulture),
					Selected = pg.PriceGroupId.ToString(CultureInfo.InvariantCulture) == property.GetValue().ToString(),
				}).ToArray());

			return dropDownList;
		}

		public bool Adapts(Control control)
		{
			return control.GetType() == typeof (SafeDropDownList);
		}

		public object GetValue(Control control)
		{
			return ((SafeDropDownList) control).SelectedItem;
		}
	}
}