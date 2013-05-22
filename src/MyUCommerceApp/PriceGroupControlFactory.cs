using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp
{
	public class PriceGroupControlFactory : IControlFactory
	{
		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName ==
				   GetType().Name.Replace("ControlFactory", "");
		}

		public Control GetControl(IProperty property)
		{
			var dropDownList = new SafeDropDownList();
			var priceGroups = PriceGroup.All().ToList();

			dropDownList.Items.Add(new ListItem { Text = "(auto)", Value = "0" });

			var listItems = priceGroups.Select(
				x => new ListItem
					     {
						     Text = string.Format("{0} ({1}%)", x.Name, x.VATRate * 100),
						     Value = x.PriceGroupId.ToString(),
						     Selected = x.PriceGroupId.ToString() == property.GetValue().ToString()
					     }).ToArray();

			dropDownList.Items.AddRange(listItems);

			return dropDownList;
		}
	}
}