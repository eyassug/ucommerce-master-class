using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.Library
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
			var ddl = new SafeDropDownList();
			var priceGroups = PriceGroup.All().ToList();

			ddl.Items.Add(new ListItem { Text = "(auto)", Value = "0" });

			var listItems = 
				priceGroups.Select(
				x => new ListItem
					{
						Text = string.Format("{0} ({1}%)", x.Name, (x.VATRate * 100).ToString("0.00")),
						Value = x.PriceGroupId.ToString(),
						Selected = x.PriceGroupId.ToString() == property.GetValue().ToString()
					}).ToList();

			ddl.Items.AddRange(listItems.ToArray());

			return ddl;
		}
	}
}
