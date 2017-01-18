using System.Collections.Generic;
using System.Linq;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.BusinessLogic.Queries
{
    public class ProductsByPropertiesQuery : ICannedQuery<Product>
    {
        private readonly string _fieldName;
        private readonly string _propertyValue;

        public ProductsByPropertiesQuery(string fieldName, string propertyValue)
        {
            _fieldName = fieldName;
            _propertyValue = propertyValue;
        }
        public IEnumerable<Product> Execute(ISession session)
        {
            return session.Query<Product>()
                .Where(product => product.ProductProperties
                    .Any(pp => pp.ProductDefinitionField.Name == _fieldName
                               && pp.Value == _propertyValue))
                .ToList();
        }
    }
}
