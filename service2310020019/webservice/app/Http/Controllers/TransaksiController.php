<?php

namespace App\Http\Controllers;

use App\Models\Transaksi;
use Illuminate\Http\Request;

class TransaksiController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Transaksi::all();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'id_keranjang' => 'required|integer',
            'status' => 'required|integer',
            'waktu_pesan' => 'required|string',
            'waktu_bayar' => 'nullable|string',
        ]);

        $transaksi = Transaksi::create($request->all());
        return response()->json($transaksi, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        return Transaksi::findOrFail($id);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $transaksi = Transaksi::findOrFail($id);
        
        $request->validate([
            'id_keranjang' => 'sometimes|required|integer',
            'status' => 'sometimes|required|integer',
            'waktu_pesan' => 'sometimes|required|string',
            'waktu_bayar' => 'nullable|string',
        ]);

        $transaksi->update($request->all());
        return response()->json($transaksi, 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $transaksi = Transaksi::findOrFail($id);
        $transaksi->delete();
        return response()->json(null, 204);
    }
}
