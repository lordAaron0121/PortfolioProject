select * from PortfolioProject..[Nashville Housing]

--standardize date format
select saledate, convert(date, saledate)
from PortfolioProject..[Nashville Housing]

--populate property address data
--replace NULL(property address) with actual address found in different rows
update a
set propertyaddress = isnull(a.propertyaddress, b.PropertyAddress) 
from PortfolioProject..[Nashville Housing] a join PortfolioProject..[Nashville Housing] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

--breakdown address into address, city, state
select substring(propertyaddress, 1, charindex(',', propertyaddress)-1) as address,
substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress)) as city
from PortfolioProject..[Nashville Housing]

alter table PortfolioProject..[Nashville Housing]
add propertysplitaddress Nvarchar(255); 

alter table PortfolioProject..[Nashville Housing]
add propertysplitcity Nvarchar(255);

update [Nashville Housing]
set propertysplitaddress = substring(propertyaddress, 1, charindex(',', propertyaddress)-1);

update [Nashville Housing]
set propertysplitcity = substring(propertyaddress, charindex(',', propertyaddress)+1, len(propertyaddress));


select owneraddress from PortfolioProject..[Nashville Housing]

select 
parsename(replace(owneraddress, ',', '.'), 3),
parsename(replace(owneraddress, ',', '.'), 2),
parsename(replace(owneraddress, ',', '.'), 1)
from PortfolioProject..[Nashville Housing]

alter table PortfolioProject..[Nashville Housing]
add ownersplitaddress Nvarchar(255); 

alter table PortfolioProject..[Nashville Housing]
add ownersplitcity Nvarchar(255); 

alter table PortfolioProject..[Nashville Housing]
add ownersplitstate Nvarchar(255); 

update [Nashville Housing]
set ownersplitaddress = parsename(replace(owneraddress, ',', '.'), 3);

update [Nashville Housing]
set ownersplitcity = parsename(replace(owneraddress, ',', '.'), 2);

update [Nashville Housing]
set ownersplitstate = parsename(replace(owneraddress, ',', '.'), 1);

--Change Y and N to Yes and No in "sold as vacant" field
select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..[Nashville Housing]
group by SoldAsVacant
order by 2

update [Nashville Housing]
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'yes'
when SoldAsVacant = 'N' then 'no'
else SoldAsVacant end
from PortfolioProject..[Nashville Housing] 

--All Y or N are replaced by Yes or No
select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..[Nashville Housing]
group by SoldAsVacant
order by 2;

--Remove duplicates
--the with block must not be separated with the select query after that
with RowNumCTE as(
select *, 
ROW_NUMBER() over (
partition by ParcelId, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueId
) row_num
from PortfolioProject..[Nashville Housing]
)
select * from RowNumCTE where row_num > 1 order by propertyaddress

--Delete unused columns
alter table PortfolioProject..[Nashville Housing]
drop column owneraddress, taxdistrict, propertyaddress

alter table PortfolioProject..[Nashville Housing]
drop column saledate
