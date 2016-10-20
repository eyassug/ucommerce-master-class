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
    public class PriceGroupControlFactory : UCommerce.Presentation.Web.Controls.IControlFactory
    {
        private IRepository<PriceGroup> _priceGroupRepository;

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
            var control = new SafeDropDownList();

            var priceGroups = _priceGroupRepository.Select().ToList();

            control.Items.Add(new ListItem("Not selected", "-1"));

            foreach (UCommerce.EntitiesV2.PriceGroup priceGroup in priceGroups)
            {
                var item = new ListItem(priceGroup.Name, priceGroup.PriceGroupId.ToString());
                item.Selected = property.GetValue().ToString() == priceGroup.PriceGroupId.ToString();

                control.Items.Add(item);
            }
            
            return control;
        }
    }
}
