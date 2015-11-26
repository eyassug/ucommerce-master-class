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
	public class PriceGroupControlFactory : IControlFactory
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

			var priceGroups = _priceGroupRepository.Select().ToList();

			dropDownList.Items.Add(new ListItem("(auto)","-1"));

			foreach (var priceGroup in priceGroups)
			{
				dropDownList.Items.Add(new ListItem(priceGroup.Name,priceGroup.PriceGroupId.ToString()));
			}

			if (property.GetValue() != null)
			{
				if (property.GetValue().ToString() != "")
				{
					dropDownList.SelectedValue = property.GetValue().ToString();
				}
			}

			dropDownList.DataBind();

			return dropDownList;
		}
	}
}
