using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.Content;
using UCommerce.EntitiesV2;
using UCommerce.Runtime;

namespace MyUCommerceApp.BusinessLogic.SiteContext
{
    public class ExtendedCatalogContext : UCommerce.Runtime.CatalogContext
    {
        public ExtendedCatalogContext(IDomainService domainService,
                                        IRepository<ProductCatalogGroup> productCatalogGroupRepository,
                                        IRepository<ProductCatalog> productCatalogRepository,
                                        IRepository<PriceGroup> priceGroupRepository) : base(domainService, productCatalogGroupRepository, productCatalogRepository, priceGroupRepository)
        {
        }

        public override string CurrentCatalogName
        {
            get
            {
                if (UserIsLoggedIn())
                {
                    return "Private";
                }

                return base.CurrentCatalogName;
            }

            set
            {
                base.CurrentCatalogName = value;
            }
        }

        private bool UserIsLoggedIn()
        {
            return System.Web.HttpContext.Current.Request.QueryString["UserIsLoggedIn"] != null;
        }
    }
}
