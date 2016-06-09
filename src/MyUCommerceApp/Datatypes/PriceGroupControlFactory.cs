using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.BusinessLogic.Datatypes
{
	public class PriceGroupControlFactory : UCommerce.Presentation.Web.Controls.IControlFactory
	{
		private readonly IRepository<PriceGroup> _priceGroupRepository;

		public PriceGroupControlFactory(IRepository<UCommerce.EntitiesV2.PriceGroup> priceGroupRepository)
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

			foreach (var priceGroup in allPriceGroups)
			{
				var listItem = new ListItem(priceGroup.Name, priceGroup.PriceGroupId.ToString());
				listItem.Selected = priceGroup.PriceGroupId.ToString() == property.GetValue().ToString();
				
				dropDownList.Items.Add(listItem);
			}

			return dropDownList;
		}
	}
}
