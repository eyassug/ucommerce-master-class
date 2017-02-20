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
        private readonly string _fieldValue;

        public ProductsByPropertiesQuery(string fieldName, string fieldValue)
        {
            _fieldName = fieldName;
            _fieldValue = fieldValue;
        }
        public IEnumerable<Product> Execute(ISession session)
        {
            return session.Query<Product>()
                .Where(x => x.ProductProperties.Any(
                    y => y.ProductDefinitionField.Name == _fieldName && y.Value == _fieldValue))
                .ToList();
        }
    }
}
