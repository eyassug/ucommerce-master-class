using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Definitions;
using UCommerce.Infrastructure;
using UCommerce.Presentation.Web.Controls;

namespace MyUCommerceApp.BusinessLogic.Datatypes
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

            dropDownList.Items.Add(new ListItem()
            {
                Text = "(auto)",
                Value = "-1"
            });

            var priceGroups = _priceGroupRepository.Select(x => x.Deleted == false).ToList();
            var propertyValue = property.GetValue().ToString();

            foreach (var priceGroup in priceGroups)
            {
                var priceGroupValue = priceGroup.PriceGroupId.ToString();
                dropDownList.Items.Add(new ListItem()
                {
                    Text = priceGroup.Name,
                    Value = priceGroupValue,
                    Selected = propertyValue == priceGroupValue
                });
            }

            return dropDownList;
        }
    }
}
