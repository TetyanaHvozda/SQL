/* Cleaning Data
*/

select *
from NashvilleHousing

-- Standardize Date Format
select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

--populate Property Address data
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.parcelID
	and a.UniqueID <> b.UniqueID
where a.propertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.parcelID
	and a.UniqueID <> b.UniqueID
where a.propertyAddress is null

--Breaking out address into individual columns (address, city, state)
select PropertyAddress
from NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
 , substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from NashvilleHousing

--split owner address
select 
parsename(replace(OwnerAddress, ',', '.') ,3)
, parsename(replace(OwnerAddress, ',', '.') ,2)
, parsename(replace(OwnerAddress, ',', '.') ,1)
from NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') ,3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') ,2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') ,1)

select *
from NashvilleHousing

--change Y and N to Yes and No in 'Sold as vacant' field
select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'yes'
	when SoldAsVacant = 'N' then 'no'
	else SoldAsVacant
	END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'yes'
	when SoldAsVacant = 'N' then 'no'
	else SoldAsVacant
	END

-- remuve duplicates
--this is all duplicates:
with rowNumCTE AS(
select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
					uniqueID
					) row_num

from NashvilleHousing
--order by ParcelID
)
delete 
from rowNumCTE
where row_num > 1
--order by PropertyAddress

select *
from NashvilleHousing

--delete unused columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress