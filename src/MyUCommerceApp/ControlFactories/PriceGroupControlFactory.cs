using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.ControlFactories
{
	public class PriceGroupControlFactory : IControlFactory
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public PriceGroupControlFactory(
			IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName ==
			       GetType().Name.Replace("ControlFactory", "");
		}

		public Control GetControl(IProperty property)
		{
			var priceGroups = _priceGroupRepository.Select().ToList();

			var listItems = priceGroups.Select(x => new ListItem
			{
				Text = x.Name, 
				Value = x.PriceGroupId.ToString(),
				Selected = property.GetValue().ToString() == x.PriceGroupId.ToString()
			});

			var defaultItem = new ListItem("(auto)", "-1");
			var dropDownList = new SafeDropDownList();
			dropDownList.Items.Add(defaultItem);
			dropDownList.Items.AddRange(listItems.ToArray());

			return dropDownList;
		}
	}
}
