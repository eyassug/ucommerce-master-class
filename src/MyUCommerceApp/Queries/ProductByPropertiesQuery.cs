using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;
using NHibernate.Linq;
namespace MyUCommerceApp.BusinessLogic.Queries
{
    public class ProductByPropertiesQuery : UCommerce.EntitiesV2.Queries.ICannedQuery<UCommerce.EntitiesV2.Product>
    {
        private string _fieldName;
        private string _fieldValue;

        public ProductByPropertiesQuery(string fieldName, string fieldValue)
        {
            _fieldName = fieldName;
            _fieldValue = fieldValue;
        }

        public IEnumerable<Product> Execute(ISession session)
        {
            return 
                session.Query<Product>()
                        .Where(product => 
                                product.ProductProperties.Any(
                                    property => property.Value == _fieldValue && 
                                    property.ProductDefinitionField.Name == _fieldName)
                                ).ToList();
        }
    }
}
