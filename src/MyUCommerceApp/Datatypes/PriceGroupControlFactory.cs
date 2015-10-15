using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.BusinessLogic.Datatypes
{
	public class PriceGroupControlFactory : IControlFactory
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
			var dropDownList = new DropDownList();
			var priceGroups = _priceGroupRepository.Select().ToList();

			dropDownList.Items.Add(new ListItem("(auto)","-1"));

			foreach (var priceGroup in priceGroups)
			{
				var listItem = new ListItem(priceGroup.Name,priceGroup.PriceGroupId.ToString());
				listItem.Selected = (priceGroup.PriceGroupId.ToString() == property.GetValue().ToString());
				dropDownList.Items.Add(listItem);
			}

			return dropDownList;
		}
	}
}
