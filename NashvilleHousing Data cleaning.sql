/*
Cleaning Data
*/

select * from PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------

--Standardize date format

select SaleDate, (cast (SaleDate as date)) from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing 
set SaleDateConverted = (cast (SaleDate as date))

select SaleDateConverted from PortfolioProject..NashvilleHousing





---------------------------------------------------------------------------------------------------------------------------

--Populate property address data
-- looking at the data, each parcel Id has same address

select PropertyAddress from PortfolioProject..NashvilleHousing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
-- can't use table name here
set PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------

-- breaking up address(Address, city, state)

select PropertyAddress from PortfolioProject..NashvilleHousing

select  
substring(PropertyAddress,1,charindex (',',PropertyAddress)-1) as Address,
substring(PropertyAddress, charindex (',',PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);
update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex (',',PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);
update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex (',',PropertyAddress)+1, len(PropertyAddress))

select * from PortfolioProject..NashvilleHousing

----- OR The easier method ---------------------------------------------------------------------------------------------------------------------

select OwnerAddress from PortfolioProject..NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing



alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);
update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);
update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);
update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from PortfolioProject..NashvilleHousing


------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes,No in "sold as vacant field"

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--------------------------------------------------------------------------------------------------------------------------

--Removing Duplicates

with RowNumCTE as (
select*,
ROW_NUMBER() over (
partition by ParcelId,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueId
			 ) row_num

from PortfolioProject..NashvilleHousing
)
select*
from RowNumCTE
where row_num>1
order by PropertyAddress


select * from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------

-- Delete Unused columns

select * from PortfolioProject..NashvilleHousing	

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

