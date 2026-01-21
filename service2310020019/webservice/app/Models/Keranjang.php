<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Keranjang extends Model
{
    protected $table = 'keranjangs';
    
    public $timestamps = false;

    protected $fillable = [
        'meja',
        'nama_pelanggan',
        'created_at',
        'updated_at',
    ];

    public function transaksi()
    {
        return $this->hasMany(Transaksi::class, 'id_keranjang');
    }
}
