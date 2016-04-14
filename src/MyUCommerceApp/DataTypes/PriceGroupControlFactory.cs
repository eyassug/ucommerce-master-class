using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.BusinessLogic.DataTypes
{
	public class PriceGroupControlFactory : UCommerce.Presentation.Web.Controls.IControlFactory
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public PriceGroupControlFactory(IRepository<PriceGroup> priceGroupRepository)
		{
			_priceGroupRepository = priceGroupRepository;
		}

		public bool Supports(DataType dataType)
		{
			return dataType.DefinitionName == "PriceGroup";
		}

		public Control GetControl(IProperty property)
		{
			var dropDownList = new SafeDropDownList();

			var allPriceGroups = _priceGroupRepository.Select().ToList();

			dropDownList.Items.Add(new ListItem("none", "-1"));
			
			foreach (var allPriceGroup in allPriceGroups)
			{
				var listItem = new ListItem(allPriceGroup.Name, allPriceGroup.PriceGroupId.ToString());
				listItem.Selected = allPriceGroup.PriceGroupId.ToString() == property.GetValue().ToString();
				dropDownList.Items.Add(listItem);
			}

			return dropDownList;
		}
	}
}
